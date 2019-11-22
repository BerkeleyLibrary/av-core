#!/usr/bin/env groovy

pipeline {
  agent {
    label "ruby-2.6.5"
  }

  environment {
    COVERAGE = 'yes'
    GENERATE_REPORTS = 'yes'
  }

  stages {
    stage("Build") {
      steps {
        sh 'bundle install'
      }
    }

    stage("Test") {
      parallel {
        stage("RSpec") {
          steps {
            sh 'bundle exec rake ci:setup:rspec spec'
          }

          post {
            always {
              junit 'spec/reports/*.xml'

              publishHTML([
                reportName: 'Code Coverage',
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: 'spec/reports/rcov',
                reportFiles: 'index.html',
              ])
            }
          }
        }

        stage("Rubocop") {
          steps {
            sh 'bundle exec rake rubocop'
          }

          post {
            always {
              publishHTML([
                reportName: 'Rubocop',
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: 'spec/reports/rubocop',
                reportFiles: 'index.html',
              ])
            }
          }
        }

        stage("Audit") {
          steps {
            sh 'bundle exec rake bundle:audit'
          }
        }
      }
    }
  }

  options {
    ansiColor("xterm")
    timeout(time: 10, unit: "MINUTES")
  }
}
