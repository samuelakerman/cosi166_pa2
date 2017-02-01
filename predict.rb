=begin
Brandeis University - Capstone Project Software Engineering
PA2 assignment - written by Samuel Akerman Jan-2017


user_id
movie_id
rating
timestamp

=end

require 'byebug'
require_relative 'movie_data.rb'

class Ratings < MovieData       
    def predict(user, movie)
        top = self.most_similar(user)
        self.return_user_movie_hash

        count = 0
        prediction = 0
        top.each do |similar|
            if !@user_movie[similar[0]].nil? ? !@user_movie[similar[0]][movie].nil? : false 
                prediction += @user_movie[similar[0]][movie]
                count += 1
            end
        end
    return prediction/count unless count==0
    return self.average_user(user)
    end
end

class Control
    def initialize train_file,test_file
        @predictor_train = Ratings.new
        @predictor_train.load_data(train_file)

        @predictor_test = Ratings.new
        @predictor_test.load_data(test_file)
    end

    def run
        validator = Validator.new @predictor_train, @predictor_test
        validator.validate
        results = validator.prediction_stats
    end

end

class Validator
    def initialize training_obj, test_obj
        @predictor_train = training_obj
        @predictor_test = test_obj
        @predicted_ratings = []
    end
    def validate
        @test_set = @predictor_test.return_data

        @test_set.each do |line|
            @predicted_ratings[@predicted_ratings.length] = @predictor_train.predict(line[0],line[1])
        end
    end
    def avg_error
        sum = 0
        j = 0
        @test_set.each do |line|
            sum += (@predicted_ratings[j] - line[2].to_f).abs
            j +=1
        end
        sum/j
    end
    def prediction_stats
        correct_predictions = {"1" => 0, "2" => 0, "3" => 0, "4" => 0, "5" => 0}
        incorrect_predictions = {"1" => 0, "2" => 0, "3" => 0, "4" => 0, "5" => 0}
        @test_set = @predictor_test.return_data

        j = 0
        @test_set.each do |line|
            if @predicted_ratings[j].round == line[2].to_i
                correct_predictions[line[2]] += 1
            else
                incorrect_predictions[line[2]] += 1
            end
            j+=1
        end
        [correct_predictions,incorrect_predictions,j]
    end
end


start_timme = Time.now
controler_predict = Control.new Dir.pwd+'/ml-100k/u1.base', Dir.pwd+'/ml-100k/u1.test'
results = controler_predict.run
end_time = Time.now
puts "The analysis took " + ((end_time - start_timme)/60).round(2).to_s + " minutes."

puts "The percentage of correctly predicted ratings by rating:"
puts "Rating of 1: " + (results[0]["1"].to_f/results[2]*100).round(1).to_s
puts "Rating of 2: " + (results[0]["2"].to_f/results[2]*100).round(1).to_s
puts "Rating of 3: " + (results[0]["3"].to_f/results[2]*100).round(1).to_s
puts "Rating of 4: " + (results[0]["4"].to_f/results[2]*100).round(1).to_s
puts "Rating of 5: " + (results[0]["5"].to_f/results[2]*100).round(1).to_s
puts " "

puts "The percentage of incorrectly assigned ratings by rating:"
puts "Rating of 1: " + (results[1]["1"].to_f/results[2]*100).round(1).to_s
puts "Rating of 2: " + (results[1]["2"].to_f/results[2]*100).round(1).to_s
puts "Rating of 3: " + (results[1]["3"].to_f/results[2]*100).round(1).to_s
puts "Rating of 4: " + (results[1]["4"].to_f/results[2]*100).round(1).to_s
puts "Rating of 5: " + (results[1]["5"].to_f/results[2]*100).round(1).to_s
