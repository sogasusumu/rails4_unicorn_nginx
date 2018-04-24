kill -QUIT `cat tmp/unicorn.pid`
bundle exec unicorn -c config/unicorn.rb -E development -D