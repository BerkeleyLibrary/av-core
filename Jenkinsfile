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
            sh 'rake ci:setup:rspec spec'
          }

          post {
            always {
              junit 'artifacts/reports/*.xml'

              publishHTML([
                reportName: 'Code Coverage',
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: 'artifacts/reports/rcov',
                reportFiles: 'index.html',
              ])
            }
          }
        }

        stage("Rubocop") {
          steps {
            sh 'rake rubocop'
          }

          post {
            always {
              publishHTML([
                reportName: 'Rubocop',
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: 'artifacts/reports/rubocop',
                reportFiles: 'index.html',
              ])
            }
          }
        }

        stage("Audit") {
          steps {
            sh 'rake bundle:audit'
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
