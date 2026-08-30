<?php

namespace Tests\Unit\Broadcasting;

use App\Broadcasting\PatientChannel;
use App\Models\User;
use PHPUnit\Framework\TestCase;

class PatientChannelTest extends TestCase
{
    public function test_patient_can_only_join_their_own_channel(): void
    {
        $user = new User;
        $user->id = 13;
        $channel = new PatientChannel;

        $this->assertTrue($channel->join($user, 13));
        $this->assertFalse($channel->join($user, 14));
    }
}
