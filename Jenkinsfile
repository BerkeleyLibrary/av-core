#!/usr/bin/env groovy

dockerComposePipeline(
    stack: [template: 'postgres'],
    commands: [
        'bundle exec rake coverage',
        'bundle exec rake rubocop',
        'bundle exec rake bundle:audit'
    ],
    artifacts: [
        junit   : 'artifacts/rspec/**/*.xml',
        html    : [
            'Code Coverage': 'artifacts/rcov',
            'RuboCop'      : 'artifacts/rubocop'
        ]
    ]
)
