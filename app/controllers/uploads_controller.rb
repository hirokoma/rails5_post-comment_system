class UploadsController < ApplicationController

  REGION = 'ap-northeast-1'
  S3_BUCKET = 'yashiro-image-store'
  AWS_ACCESS_KEY_ID = 'YOUR_AWS_ACCESS_KEY_ID'
  AWS_SECRET_KEY = 'AWS_SECRET_KEY'
  ACL = 'public-read'
  STATUS = '200'

  def issue_upload_token
    # 0. セッションの確認など

    # 1. 画像情報をバリデーションする
    # ファイルサイズは大き過ぎないか、種類は適切か、など。
    is_valid = params[:csize] and
               params[:csize].is_a? Numeric and 
               params[:csize] > 0 and
               params[:csize] < 5 * 1024 * 1024 and 
               params[:ctype] and 
               params[:ctyep].is_a? String and

    if not is_valid
      render json: { error: 'invalid parameter' }
    end

    now = Time.now
    expiration = (now + 1.minute).utc
    rand1 = [*1..9].sample(10).join
    rand2 = [*1..9].sample(10).join
    rand3 = [*1..9].sample(10).join
    rand4 = [*1..9].sample(10).join

    key = now.utc.to_i.to_s + '-' + 
          rand1 + '-' + 
          rand2 + '-' + 
          rand3 + '-' +
          rand4

    ctype = params[:ctype]
    csize = params[:csize]

    policy_document = {
      expiration: expiration,
      conditions: [
        { bucket: S3_BUCKET },
        { key: key },
        { acl: ACL },
        { 'Content-Type' => ctype },
        [ 'content-length-range', csize, csize ]
      ]
    }.to_json

    policy = Base64.encode64(policy_document).gsub("\n", '')

    signature = Base64.encode64(
        OpenSSL::HMAC.digest(
            OpenSSL::Digest::Digest.new('sha1'),
            AWS_SECRET_KEY, policy)).gsub("\n", '')

    render json: {
      key: key,
      AWSAccessKeyId: AWS_ACCESS_KEY_ID,
      acl: ACL,
      policy: policy,
      signature: signature,
      
      'Content-Type': ctype
    }
  end

end
