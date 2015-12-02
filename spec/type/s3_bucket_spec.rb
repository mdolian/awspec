require 'spec_helper'
Awspec::Stub.load 's3_bucket'

describe s3_bucket('my-bucket') do
  it { should exist }
  it { should have_object('path/to/object') }

  its(:acl_owner) { should eq 'my-bucket-owner' }
  its(:acl_grants_count) { should eq 3 }
  it { should have_acl_grant(grantee: 'my-bucket-owner', permission: 'FULL_CONTROL') }
  it { should have_acl_grant(grantee: 'my-bucket-write-only', permission: 'WRITE') }
  it { should have_acl_grant(grantee: 'my-bucket-read-only', permission: 'READ') }

  it do
    should have_policy <<-POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
    POLICY
  end
end

# deprecated
describe s3('my-bucket') do
  it { should exist }
  it { should have_object('path/to/object') }
  its(:acl_grants_count) { should eq 3 }
  it { should have_acl_grant(grantee: 'my-bucket-owner', permission: 'FULL_CONTROL') }
  it { should have_acl_grant(grantee: 'my-bucket-write-only', permission: 'WRITE') }
  it { should have_acl_grant(grantee: 'my-bucket-read-only', permission: 'READ') }
  its(:acl_owner) { should eq 'my-bucket-owner' }
end
