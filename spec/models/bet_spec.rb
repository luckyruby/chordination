require 'spec_helper'

describe Bet do
  it "is valid with a name, bet_type, and scoresheet" do
    user = User.create(name: 'John', email: 'text@example.com', password: '123456')
    scoresheet = user.scoresheets.build(name: 'Test', deadline: '2013-06-22 12:00')
    bet = scoresheet.bets.build(name: 'Test', bet_type: 'differential')
    expect(bet).to be_valid
  end
  
  it "is invalid without a name" do
    expect(Bet.new(name: nil)).to have(1).errors_on(:name)
  end

  it "is invalid without a bet_type" do
    expect(Bet.new(bet_type: nil)).to have(1).errors_on(:bet_type)
  end
  
  it "is invalid without choices if bet_type is winner" do
    expect(Bet.new(bet_type: 'winner', choices: nil)).to have(1).errors_on(:choices)
  end
  
  it "requires choices to have more than 1 if bet_type is winner" do
    expect(Bet.new(bet_type: 'winner', choices: 'one')).to have(1).errors_on(:choices)
  end
  
  it "does not allow duplicate names per scoresheet" do
    user = User.create(name: 'John', email: 'text@example.com', password: '123456')
    scoresheet = user.scoresheets.create(name: 'Test', deadline: '2013-06-22 12:00')
    scoresheet.bets.create(name: 'Test', bet_type: 'differential')
    bet = scoresheet.bets.build(name: 'Test', bet_type: 'differential')
    expect(bet).to have(1).errors_on(:name)
  end
end