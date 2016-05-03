class CreateOutcomeResultsFromQuizSubmission
  include Interactor

  def call
    @quiz_submission = context.quiz_submission
    user = context.user
    outcome_results = []
    if @quiz_submission.initial
      @quiz_submission.answers.each do |answer|
        next unless answer.option.question.outcome
        if answer.option.correct
          outcome_results << OutcomeResult.new(user: user,
                                               outcome: answer.option.question.outcome,
                                               rating: 3,
                                               source: answer.option.question)
        else
          outcome_results << OutcomeResult.new(user: user,
                                               outcome: answer.option.question.outcome,
                                               rating: 1,
                                               source: answer.option.question)
        end
      end
      if @quiz_submission.answers.count < @quiz_submission.quiz.questions.count
        answer_question_ids = @quiz_submission.answers.map { |a| a.option.question.id }
        unanswered_questions = @quiz_submission.quiz.questions.select { |question| question.outcome && answer_question_ids.exclude?(question.id) }
        unanswered_questions.each do |question|
          outcome_results << OutcomeResult.new(user: user,
                                               outcome: question.outcome,
                                               rating: 1,
                                               source: question)
        end
      end
    end
    OutcomeResult.transaction do
      outcome_results.each(&:save!)
    end
    rescue ActiveRecord::RecordInvalid => exception
      context.fail!(error: exception.message)
  end
end
