#!/bin/sh

arch -x86_64 /usr/local/opt/ruby/bin/bundle update 
arch -x86_64 /usr/local/opt/ruby/bin/bundle install 

#export SSL_CERT_FILE=_source/cacert.pem
arch -x86_64 /usr/local/opt/ruby/bin/bundle exec jekyll serve --incremental --drafts
