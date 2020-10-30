class Challenge
  def challenges
    require 'net/http'
    require 'uri'
    uri = URI.parse('http://challenge.z2o.cloud/challenges')
    
    while true
      params = { nickname: "takiguchi" }
      #postレスポンス
      postRes = Net::HTTP.post_form(uri, params)
      id = postRes.body[7..70]
      #現在日時(unix時間で取得)
      nowTime = Time.now.strftime('%s%L').to_i.to_s
      #呼出予定時刻
      callTime = postRes.body[86..98]#json形式から時間を抽出
      #タイマーで予定時刻まで待機
      self.class.timer(callTime, nowTime)
      putRes = self.class.put_Req(id,uri)
      #差異時刻
      totalDiff = putRes.body[139..141]#json形式から時間を抽出
      #呼出時刻
      callTime = putRes.body[86..98]#json形式から時間を抽出

      while true
        #呼出時刻になるまで待機
        self.class.timer(callTime, nowTime)
        putRes = self.class.put_Req(id,uri)
        callTime = putRes.body[86..98]
        totalDiff = putRes.body[139..141]

        #差異時間が0(nil)になったら終了
        unless totalDiff
            puts putRes.body
          return true
        end
      end
    end
  end

  #チャレンジID(id)をX-Challenge-Idヘッダに付与
  def self.put_Req(id,uri)
    putReq = Net::HTTP::Put.new(uri, initheader = { 'X-Challenge-Id' => id})
    putRes = Net::HTTP.new(uri.host, uri.port).start {|challenge| challenge.request(putReq) }
    return putRes
  end
  
  #タイマー, 呼出時間と現在時間が一致
  def self.timer(callTime,nowTime)
    until callTime == nowTime
        nowTime = Time.now.strftime('%s%L').to_i.to_s
    end
  end
end

a = Challenge.new
a.challenges
