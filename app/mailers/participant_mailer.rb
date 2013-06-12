class ParticipantMailer < ActionMailer::Base
  default from: "Chordination <klin@luckyruby.com>"
  
  def invitation_email(participant)
    @participant = participant
    mail(to: participant.email, subject: "You've been invited to bet on \"#{@participant.scoresheet.name}\"")
  end

end