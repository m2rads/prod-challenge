require 'daru'

class SiteController < ApplicationController
  def index
      @question = Question.find(3)
  end

  def ask
    embedding_service = EmbeddingService.instance

    question_asked = params[:question].presence || ""
    if !question_asked.end_with?("?")
      question_asked += "?"
    end

    previous_question = Question.find_by(question_text: question_asked)

    if previous_question
      print "previously asked and answered \n === \n " + previous_question.answer + " \n==="
      previous_question.ask_count = previous_question.ask_count + 1
      print "\n ask count" + previous_question.ask_count.to_s + " \n=== "
      previous_question.save()
      render json: {
        question: previous_question.question_text,
        answer: previous_question.answer,
        id: previous_question.id
      }
      return
    end

    df = Daru::DataFrame.from_csv('./lib/assets/getting-real.pdf.pages.csv')
    document_embeddings = embedding_service.load_embeddings("./lib/assets/getting-real.pdf.embeddings.csv")
    answer, context = embedding_service.answer_query_with_context(question_asked, df, document_embeddings)

    question = Question.create(question_text:question_asked, answer:answer)
    question.save()

    puts "new question: "
    puts question.question_text
    puts question.ask_count

    render json: {
      question: question.question_text,
      answer: answer,
      id: question.id
    }
    end
end
