=begin
Brandeis University - Capstone Project Software Engineering
Written by Samuel Akerman Jan-2017
=end


require 'byebug'

class MovieData
    def initialize
       @data = []       #@data is an array of arrays. Each cell has an array with: user_id, movie_id, rating, timestamp
       @stats = Hash.new   #@stats: key = movie_id, value = vector with two positions: avg rating, # of raters
       @similar_users = Hash.new
    end

    def load_data(path)
        file = File.open(path)
        count = -1
        file.each_line do |line|
            fields =  line.split("\t")[0..2]  #fields are separated by tabs
            @data[count += 1] = fields  #read all lines. Create a new entry in the array per each line [[],[],[]...]
        end
        self.user_movie_hash
    end
    def user_movie_hash                 #this method creates a hash in which key = user_id
        @user_movie = Hash.new          #and value is another hash where key = movie, and value=rating
        @data.each do |line| 
            if @user_movie[line[0]].nil?
                @user_movie[line[0]] = Hash.new
                @user_movie[line[0]][line[1]] = line[2].to_f
            else
                @user_movie[line[0]][line[1]] = line[2].to_f
            end
        end
    end    
    def return_user_movie_hash
        @user_movie.empty? ? @user_movie : self.user_movie_hash

    end
    def return_data
        @data
    end
    def calc_popularity         #this methods calculates the average rating for every movie in the data
        @data.each do |line|
            if @stats[line[1]].nil?            #line[0]=user_id, [1]=movie_id, [2]=rating, [3]=timestamp
                @stats[line[1]] = [line[2].to_f,1]  #each value in hash @stats is an array with two positions: avg rating, # of raters
            else
                avg_rating = @stats[line[1]][0]
                no_raters = @stats[line[1]][1].to_f

                @stats[line[1]][1]+=1          #increase by 1 the number of people who've rated this movie
                @stats[line[1]][0] = (avg_rating*no_raters.to_f + line[2].to_f)/(no_raters.to_f+1)  #calculate new average
            end
        end
    end
    def popularity(movie_id)
        self.calc_popularity unless !@stats.empty?    #if calc_popularity was already called no point in calling it again
        @stats[movie_id][0].round(2)                  #return the movie popularity rating rounding at 2 decimals
    end

    def popularity_list 
        count = -1
        list = Array.new
        sorted_hash = (@stats.sort_by {|key, value| value}).reverse         #create a sorted array with stat hash contents
        sorted_hash.each do |x| 
            list[count+=1] = [x[0],x[1][0]]             #create an array containing movie ID and rating
        end
        list
    end
    def average_user user
        sum = 0
        count = 0
        if @user_movie[user].nil?
            return 4
        end
        @user_movie[user].each do |line|
            sum += line[1]
            count += 1
        end
        count == 0 ? 4 : sum/count
    end
    def similarity(user1,user2)
        user1_movies = @user_movie[user1]
        user2_movies = @user_movie[user2]
        
        no_common_movies = 0
        common_movie_rating = Array.new     #array in which each cell is a vector with the ratings given by user1 and user 2 to the same movie
        user1_movies.each do |movies1|
            
            if user2_movies.nil? ? false : !user2_movies[movies1[0]].nil?  
                no_common_movies+=1
                common_movie_rating[common_movie_rating.length]=[movies1[1],user2_movies[movies1[0]]] 
            end
        end
        if no_common_movies > 0     #the two users did watch some of the same movies
            difference = 0
            common_movie_rating.each do |x|
                difference += (x[0].to_i-x[1].to_i).abs     #let's see how their opinions differ in regards to a particular movie
            end
            difference_prop = 1 - difference/(4*common_movie_rating.length) #for the common movies, difference_prop is 1 if
            #                                                               the ratings given were all the same to the same movies
            sim_index = 0.3*no_common_movies/user1_movies.length+0.3*no_common_movies/user2_movies.length+0.4*difference_prop
            #sim_index ranges between 0 and 1
            #this index has three componentes, 1) 30% corresponds to the % of common movies by user1
            #                                  2) 30% corresponds to the % of common movies by user2
            #                                  3) 40% corresponds to the exent to which the two users rated the movies similarly
            return sim_index.round(3)
        else
            return 0            #if the two users didn't wach any common movies, similarity index = 0
        end
    end

    def most_similar(user)
        if @similar_users[user].nil?
            users = Hash.new                                #hash with a list of all users except *user*
            @data.each do |line|
                if users[line[0]].nil? && line[0]!=user       
                    users[line[0]] = 0                      #init hash
                end
            end
            users.each do |u|
                users[u[0]] = self.similarity(u[0],user)    #calculate similarity index between *user* and the rest. Store in hash
            end
            similarity_list=(users.sort_by {|key, value| value}).reverse       #sort and reverse hash
            top = similarity_list[0..20]                                        #return an array with the top 100 most similar users to *user*
            @similar_users[user] = top
            return top
        else
            return @similar_users[user]
        end
    end
end
