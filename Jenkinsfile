#!/usr/bin/env groovy

dockerComposePipeline(
    stack: [template: 'postgres'],
    commands: [
        'rake coverage',
        'rake rubocop',
        'rake bundle:audit'
    ],
    artifacts: [
        junit   : 'artifacts/rspec/**/*.xml',
        html    : [
            'Code Coverage': 'artifacts/rcov',
            'RuboCop'      : 'artifacts/rubocop'
        ]
    ]
)
