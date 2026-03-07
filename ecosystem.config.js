module.exports = {
    apps: [
        {
            name: 'klyvo-api',
            cwd: './backend',
            script: 'dist/main.js',
            instances: 1,
            env: {
                NODE_ENV: 'production',
                PORT: 3000,
            },
            max_memory_restart: '500M',
            log_date_format: 'YYYY-MM-DD HH:mm:ss',
        },
        {
            name: 'klyvo-web',
            cwd: './frontend',
            script: 'node_modules/.bin/next',
            args: 'start -p 3001',
            instances: 1,
            env: {
                NODE_ENV: 'production',
            },
            max_memory_restart: '500M',
            log_date_format: 'YYYY-MM-DD HH:mm:ss',
        },
    ],
};
