require 'spec_helper'

describe Scoresheet do
  it "is valid with a user, name, and deadline" do
    user = User.create(name: 'John', email: 'text@example.com', password: '123456')
    scoresheet = user.scoresheets.build(name: 'Test', deadline: '2013-06-22 12:00')
    expect(scoresheet).to be_valid
  end
  
  it "is invalid without a name" do
    expect(Scoresheet.new(name: nil)).to have(1).errors_on(:name)
  end
  
  it "is invalid without a deadline" do
    expect(Scoresheet.new(deadline: nil)).to have(1).errors_on(:deadline)
  end
  
  it "is invalid without a user" do
    expect(Scoresheet.new(name: 'Test', deadline: '2013-06-22 12:00')).to have(1).errors_on(:user_id)
  end
  
  it "does not allow duplicate names per user" do
    user = User.create(name: 'John', email: 'text@example.com', password: '123456')
    user.scoresheets.create(name: 'Test', deadline: '2013-06-22 12:00')
    scoresheet = user.scoresheets.build(name: 'Test', deadline: '2013-06-22 14:00')
    expect(scoresheet).to have(1).errors_on(:name)
  end
  
end