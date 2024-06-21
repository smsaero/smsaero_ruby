require 'net/http'
require 'uri'
require 'json'

module SmsAeroApi

  class SmsAeroError < StandardError
    # SmsAero Errors
  end

  class SmsAeroHTTPError < SmsAeroError
    # A Connection error occurred
  end

  class SmsAeroConnectionError < SmsAeroError
    # A Connection error occurred
  end

  class SmsAero
    GATE_URLS = [
      '@gate.smsaero.ru/v2/',
      '@gate.smsaero.org/v2/',
      '@gate.smsaero.net/v2/',
      '@gate.smsaero.uz/v2/'
    ]
    SIGNATURE = 'SMS Aero'
    TYPE_SEND = 2

    def initialize(email, api_key, url_gate: nil, signature: SIGNATURE, type_send: TYPE_SEND)
      @session = Net::HTTP
      @uri = URI(url_gate || GATE_URLS.first)
      @email = email
      @api_key = api_key
      @signature = signature
      @type_send = type_send
    end

    def send(number, text, date_send = nil, callback_url = nil)
      num, number = get_num(number)
      data = {
        num => number,
        'sign' => @signature,
        'text' => text,
        'callbackUrl' => callback_url
      }

      if !date_send.nil?
        if date_send.is_a?(Time)
          data['dateSend'] = date_send.to_i
        else
          raise SmsAeroError, 'param `date` is not a Time object'
        end
      end

      request('sms/send', data)
    end

    def sms_status(sms_id)
      request('sms/status', { 'id' => sms_id })
    end

    def sms_list(number = nil, text = nil, page = nil)
      data = {}
      if number
        data['number'] = number.to_s
      end
      if text
        data['text'] = text
      end
      request('sms/list', data, page)
    end

    def balance
      request('balance')
    end

    def auth
      request('auth')
    end

    def cards
      request('cards')
    end

    def add_balance(_sum, card_id)
      request('balance/add', { 'sum' => _sum, 'cardId' => card_id })
    end

    def tariffs
      request('tariffs')
    end

    def sign_list(page = nil)
      request('sign/list', nil, page)
    end

    def group_add(name)
      request('group/add', { 'name' => name })
    end

    def group_delete(group_id)
      request('group/delete', { 'id' => group_id })
    end

    def group_list(page = nil)
      request('group/list', nil, page)
    end

    def contact_add(number, group_id = nil, birthday = nil, sex = nil, lname = nil, fname = nil, sname = nil, param1 = nil, param2 = nil, param3 = nil)
      request('contact/add', {
        'number' => number.to_s,
        'groupId' => group_id,
        'birthday' => birthday,
        'sex' => sex,
        'lname' => lname,
        'fname' => fname,
        'sname' => sname,
        'param1' => param1,
        'param2' => param2,
        'param3' => param3
      })
    end

    def contact_delete(contact_id)
      request('contact/delete', { 'id' => contact_id })
    end

    def contact_list(number = nil, group_id = nil, birthday = nil, sex = nil, operator = nil, lname = nil, fname = nil, sname = nil, page = nil)
      request('contact/list', {
        'number' => number && number.to_s,
        'groupId' => group_id,
        'birthday' => birthday,
        'sex' => sex,
        'operator' => operator,
        'lname' => lname,
        'fname' => fname,
        'sname' => sname
      }, page)
    end

    def blacklist_add(number)
      num, number = get_num(number)
      request('blacklist/add', { num => number })
    end

    def blacklist_list(number = nil, page = nil)
      data = number && { 'number' => number.to_s }
      request('blacklist/list', data, page)
    end

    def blacklist_delete(blacklist_id)
      request('blacklist/delete', { 'id' => blacklist_id.to_i })
    end

    def hlr_check(number)
      num, number = get_num(number)
      request('hlr/check', { num => number })
    end

    def hlr_status(hlr_id)
      request('hlr/status', { 'id' => hlr_id.to_i })
    end

    def number_operator(number)
      num, number = get_num(number)
      request('number/operator', { num => number })
    end

    def viber_send(sign, channel, text, number = nil, group_id = nil, image_source = nil, text_button = nil, link_button = nil, date_send = nil, sign_sms = nil, channel_sms = nil, text_sms = nil, price_sms = nil)
      num, number = get_num(number)
      request('viber/send', {
        num => number,
        'groupId' => group_id && group_id.to_i,
        'sign' => sign && sign.to_s,
        'channel' => channel && channel.to_s,
        'text' => text,
        'imageSource' => image_source,
        'textButton' => text_button,
        'linkButton' => link_button,
        'dateSend' => date_send,
        'signSms' => sign_sms,
        'channelSms' => channel_sms,
        'textSms' => text_sms,
        'priceSms' => price_sms
      })
    end

    def viber_sign_list
      request('viber/sign/list')
    end

    def viber_list(page = nil)
      request('viber/list', nil, page)
    end

    private

    def request(selector, data = nil, page = nil, proto = 'https')
      get_gate_urls.each do |gate|
        begin
          uri = URI.join("#{proto}://#{gate}", selector)
          if page
            uri.query = URI.encode_www_form(page: page)
          end
          http = @session.new(uri.host, uri.port)
          http.use_ssl = (proto == 'https')
          request = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
          request.basic_auth @email, @api_key
          request.body = data.to_json if data
          response = http.request(request)
          # puts response.body
          return check_response(response.body)
        rescue OpenSSL::SSL::SSLError
          proto = 'http'
          retry
        rescue Errno::ECONNREFUSED
          next
        end
      end
      raise SmsAeroConnectionError, 'All connection attempts failed'
    end

    def get_gate_urls
      @url_gate ? [@url_gate] : GATE_URLS
    end

    def check_response(response)
      result = JSON.parse(response)
      raise SmsAeroHTTPError, result['message'] unless result['success']
      result['data']
    end

    def get_num(number)
      if number.is_a?(Array)
        num = 'numbers'
      else
        num = 'number'
        number = number.to_s
      end
      [num, number]
    end
  end

end
