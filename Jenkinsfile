#!/usr/bin/env groovy

@Library('jenkins-workflow-scripts@master') _

dockerComposePipeline(
    commands: [
        'bundle exec rake coverage',
        'bundle exec rake rubocop',
        'bundle exec rake bundle:audit',
        'bundle exec rake gem'
    ],
    artifacts: [
        junit   : 'artifacts/rspec/**/*.xml',
        html    : [
            'Code Coverage': 'artifacts/rcov',
            'RuboCop'      : 'artifacts/rubocop'
        ],
        raw: 'artifacts/**/*.gem'
    ]
)
