<?php

it('allows configured browser origins to call the API', function () {
    $origin = 'http://localhost:3055';

    $this->optionsJson('/api/profile', [], [
        'Access-Control-Request-Headers' => 'authorization,content-type',
        'Access-Control-Request-Method' => 'GET',
        'Origin' => $origin,
    ])->assertSuccessful()
        ->assertHeader('Access-Control-Allow-Origin', $origin)
        ->assertHeader('Access-Control-Max-Age', '600');
});

it('does not grant CORS access to unapproved origins', function () {
    $this->optionsJson('/api/profile', [], [
        'Access-Control-Request-Headers' => 'authorization,content-type',
        'Access-Control-Request-Method' => 'GET',
        'Origin' => 'https://attacker.example',
    ])->assertHeaderMissing('Access-Control-Allow-Origin');
});
