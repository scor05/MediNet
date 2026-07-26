<?php

namespace Tests\Unit\Repositories;

use App\Models\ClientUser;
use App\Repositories\ClientUserRepository;
use Mockery;
use Mockery\Adapter\Phpunit\MockeryPHPUnitIntegration;
use PHPUnit\Framework\Attributes\PreserveGlobalState;
use PHPUnit\Framework\Attributes\RunInSeparateProcess;
use PHPUnit\Framework\TestCase;

class ClientUserRepositoryTest extends TestCase
{
    use MockeryPHPUnitIntegration;

    #[RunInSeparateProcess]
    #[PreserveGlobalState(false)]
    public function test_update_uses_both_composite_key_columns_and_reloads_the_record(): void
    {
        $data = [
            'role' => 2,
            'is_admin' => true,
            'is_active' => true,
        ];
        $updated = (object) array_merge([
            'id_client' => 1,
            'id_user' => 12,
        ], $data);

        $lookupQuery = Mockery::mock();
        $updateQuery = Mockery::mock();
        $reloadQuery = Mockery::mock();
        $model = Mockery::mock('alias:'.ClientUser::class);

        $model->shouldReceive('where')
            ->times(3)
            ->with('id_client', 1)
            ->andReturn($lookupQuery, $updateQuery, $reloadQuery);

        $lookupQuery->shouldReceive('where')
            ->once()
            ->with('id_user', 12)
            ->andReturnSelf();
        $lookupQuery->shouldReceive('firstOrFail')->once();

        $updateQuery->shouldReceive('where')
            ->once()
            ->with('id_user', 12)
            ->andReturnSelf();
        $updateQuery->shouldReceive('update')
            ->once()
            ->with($data)
            ->andReturn(1);

        $reloadQuery->shouldReceive('where')
            ->once()
            ->with('id_user', 12)
            ->andReturnSelf();
        $reloadQuery->shouldReceive('firstOrFail')
            ->once()
            ->andReturn($updated);

        $result = (new ClientUserRepository)->update(1, 12, $data);

        $this->assertSame($updated, $result);
    }
}
