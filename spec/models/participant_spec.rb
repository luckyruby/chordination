require 'spec_helper'

describe Participant do
  it "is valid with a name, email, key, and scoresheet" do
    user = User.create(name: 'John', email: 'test@example.com', password: '123456')
    scoresheet = user.scoresheets.create(name: 'Test', deadline: '2013-06-22 12:00')
    ken = scoresheet.participants.create(name: 'Ken', email: 'ken@example.com')
    expect(ken).to be_valid
  end
  
  it "is invalid without a name" do
    expect(Participant.new(name: nil)).to have(1).errors_on(:name)
  end
  
  it "is invalid without a email" do
    expect(Participant.new(email: nil)).to have(1).errors_on(:email)
  end
  
  it "is invalid without a scoresheet" do
    participant = Participant.new(name: 'John', email: 'test@example.com')
    expect(participant).to have(1).errors_on(:scoresheet)
  end
  
  it "is invalid without a key" do
    user = User.create(name: 'John', email: 'test@example.com', password: '123456')
    scoresheet = user.scoresheets.create(name: 'Test', deadline: '2013-06-22 12:00')
    ken = scoresheet.participants.create(name: 'Ken', email: 'ken@example.com')
    ken.key = nil
    ken.save
    expect(ken).to have(1).errors_on(:key)
  end
  
  it "requires a unique name per scoresheet" do
    user = User.create(name: 'John', email: 'test@example.com', password: '123456')
    scoresheet = user.scoresheets.create(name: 'Test', deadline: '2013-06-22 12:00')
    scoresheet.participants.create(name: 'Ken', email: 'ken@example.com')
    ken = scoresheet.participants.build(name: 'Ken', email: 'ken2@example.com')
    expect(ken).to have(1).errors_on(:name)
  end
  
  it "requires a unique email per scoresheet" do
    user = User.create(name: 'John', email: 'test@example.com', password: '123456')
    scoresheet = user.scoresheets.create(name: 'Test', deadline: '2013-06-22 12:00')
    scoresheet.participants.create(name: 'Ken', email: 'ken@example.com')
    jeff = scoresheet.participants.build(name: 'Jeff', email: 'ken@example.com')
    expect(jeff).to have(1).errors_on(:email)
  end
  
  it "requires a unique key" do
    user = User.create(name: 'John', email: 'text@example.com', password: '123456')
    scoresheet = user.scoresheets.create(name: 'Test', deadline: '2013-06-22 12:00')
    bryan = scoresheet.participants.create(name: 'Bryan', email: 'bryan@example.com')
    bryan.key = 'some_key'
    bryan.save
    matt = scoresheet.participants.create(name: 'Matt', email: 'matt@example.com')
    matt.key = 'some_key'
    matt.save
    expect(matt).to have(1).errors_on(:key)    
  end
end