require 'spec_helper'

describe User do
  it "is valid with a name, email and password" do
    user = User.new(
      name: 'John Doe',
      email: 'test@example.com',
      password: 'password')
    expect(user).to be_valid
  end
  
  it "is invalid without a name" do
    expect(User.new(name: nil)).to have(1).errors_on(:name)
  end
  
  it "is invalid without an email" do
    expect(User.new(email: nil)).to have(1).errors_on(:email)
  end
  
  it "is invalid without a password" do
    expect(User.new(password: nil)).to have(1).errors_on(:password)    
  end
  
  it "is invalid with a duplicate email" do
    User.create(name: 'John Doe', email: 'test@example.com', password: '123456')
    user = User.create(name: 'John Doe2', email: 'test@example.com', password: '123456')
    expect(user).to have(1).errors_on(:email)
  end
  
  it "is invalid if password is < 6 characters" do
    expect(User.new(password: '12345')).to have(1).errors_on(:password)
  end
  
  it "is invalid without a valid email" do
    expect(User.new(email: 'invalidemail')).to have(1).errors_on(:email)
  end
end