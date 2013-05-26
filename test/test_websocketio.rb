require File.expand_path 'test_helper', File.dirname(__FILE__)

class TestWebSocketIO < MiniTest::Test

  def setup
    App.start
  end

  def teardown
    App.stop
  end

  def test_simple
    res = nil
    post_data = {:time => Time.now.to_s, :msg => 'hello!!'}
    client = Sinatra::WebSocketIO::Client.new(App.websocketio_url).connect

    client.on :broadcast do |data|
      res = data
      client.close
    end

    client.on :disconnect do
    end

    client.on :connect do |session|
      push :broadcast, post_data
    end

    50.times do
      break if res != nil
      sleep 0.1
    end
    client.close
    assert res != nil, 'server not respond'
    assert res["time"] == post_data[:time]
    assert res["msg"] == post_data[:msg]
  end

  def test_client_to_client2
    ## client --> server --> client2
    post_data = {:time => Time.now.to_s, :msg => 'hello!!', :to => nil}
    res = nil
    res2 = nil
    client = Sinatra::WebSocketIO::Client.new(App.websocketio_url).connect
    client.on :message do |data|
      res = data
    end

    client.on :connect do |session|
      client2 = Sinatra::WebSocketIO::Client.new(App.websocketio_url).connect
      client2.on :connect do |session2|
        post_data['to'] = session2
        client.push :message, post_data
      end
      client2.on :message do |data|
        res2 = data
        client2.close
        client.close
      end
    end

    50.times do
      break if res != nil
      sleep 0.1
    end
    client.close
    assert res2 != nil, 'server not respond'
    assert res2["time"] == post_data[:time]
    assert res2["msg"] == post_data[:msg]
    assert res == nil
  end


  def test_broadcast
    ## client --> server --> client&client2
    post_data = {:time => Time.now.to_s, :msg => 'hello!!'}
    res = nil
    res2 = nil

    client = Sinatra::WebSocketIO::Client.new(App.websocketio_url).connect
    client.on :broadcast do |data|
      res = data
    end

    client.on :connect do |session|
      client2 = Sinatra::WebSocketIO::Client.new(App.websocketio_url).connect
      client2.on :connect do |session2|
        client.push :broadcast, post_data
      end
      client2.on :broadcast do |data|
        res2 = data
        client2.close
      end
    end

    50.times do
      break if res != nil and res2 != nil
      sleep 0.1
    end
    client.close

    assert res != nil, 'server not respond'
    assert res["time"] == post_data[:time]
    assert res["msg"] == post_data[:msg]
    assert res2 != nil
    assert res2["time"] == post_data[:time]
    assert res2["msg"] == post_data[:msg]
  end

end
