<?php

namespace Tests\Unit\Models;

use App\Models\Clinic;
use PHPUnit\Framework\TestCase;

class ClinicTest extends TestCase
{
    public function test_client_and_active_status_are_mass_assignable(): void
    {
        $clinic = new Clinic;

        $clinic->fill([
            'name' => 'San Pedro',
            'address' => 'Zona 8',
            'phone' => '12121212',
            'email' => 'clinica@example.com',
            'id_client' => 4,
            'is_active' => false,
        ]);

        $this->assertSame(4, $clinic->id_client);
        $this->assertFalse($clinic->is_active);
    }
}
