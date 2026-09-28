<?php

namespace Tests\Unit\Broadcasting;

use App\Broadcasting\DoctorChannel;
use App\Models\User;
use PHPUnit\Framework\TestCase;

class DoctorChannelTest extends TestCase
{
    public function test_active_doctor_can_only_join_their_own_channel(): void
    {
        $user = new User;
        $user->id = 7;
        $user->is_active = true;
        $channel = new DoctorChannel;

        $this->assertTrue($channel->join($user, 7));
        $this->assertFalse($channel->join($user, 8));

        $user->is_active = false;
        $this->assertFalse($channel->join($user, 7));
    }
}
