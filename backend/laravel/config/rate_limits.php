<?php

return [
    /*
    |--------------------------------------------------------------------------
    | API rate limits (requests per minute)
    |--------------------------------------------------------------------------
    |
    | Public endpoints are limited by IP address. Authenticated endpoints use
    | the local user ID after Supabase authentication whenever it is available.
    |
    */
    'registration' => (int) env('RATE_LIMIT_REGISTRATION', 5),
    'token_validation' => (int) env('RATE_LIMIT_TOKEN_VALIDATION', 120),
    'authenticated' => (int) env('RATE_LIMIT_AUTHENTICATED', 120),
    'public_search' => (int) env('RATE_LIMIT_PUBLIC_SEARCH', 60),
    'public_slots' => (int) env('RATE_LIMIT_PUBLIC_SLOTS', 30),
    'creation' => (int) env('RATE_LIMIT_CREATION', 20),
];
