<?php

namespace Tests\Unit\Repositories;

use App\Repositories\SearchRepository;
use Illuminate\Support\Facades\DB;
use Mockery;
use Mockery\Adapter\Phpunit\MockeryPHPUnitIntegration;
use PHPUnit\Framework\Attributes\PreserveGlobalState;
use PHPUnit\Framework\Attributes\RunInSeparateProcess;
use PHPUnit\Framework\TestCase;

class SearchRepositoryTest extends TestCase
{
    use MockeryPHPUnitIntegration;

    #[RunInSeparateProcess]
    #[PreserveGlobalState(false)]
    public function test_search_doctors_filters_by_name_or_specialty(): void
    {
        $results = [(object) ['id' => 8, 'name' => 'Ana Lopez', 'specialty' => 'Cardiologia']];
        $query = Mockery::mock();
        $db = Mockery::mock('alias:'.DB::class);

        $db->shouldReceive('table')->once()->with('users')->andReturn($query);
        $db->shouldReceive('raw')
            ->once()
            ->with("COALESCE(MIN(specialties.specialty), 'Sin especialidad') as specialty")
            ->andReturn('specialty_expression');

        $query->shouldReceive('join')
            ->once()
            ->with('client_users AS cu', 'cu.id_user', '=', 'users.id')
            ->andReturnSelf();
        $query->shouldReceive('leftJoin')->twice()->andReturnSelf();
        $query->shouldReceive('where')->once()->with('cu.role', 1)->andReturnSelf();
        $query->shouldReceive('where')->once()->with('cu.is_active', true)->andReturnSelf();
        $query->shouldReceive('where')->once()->with('users.is_active', true)->andReturnSelf();
        $query->shouldReceive('select')
            ->once()
            ->with('users.id', 'users.name', 'specialty_expression')
            ->andReturnSelf();
        $query->shouldReceive('groupBy')
            ->once()
            ->with('users.id', 'users.name')
            ->andReturnSelf();
        $query->shouldReceive('where')
            ->once()
            ->with(Mockery::on(function ($filter): bool {
                $nestedQuery = Mockery::mock();
                $nestedQuery->shouldReceive('where')
                    ->once()
                    ->with('users.name', 'ILIKE', '%cardio%')
                    ->andReturnSelf();
                $nestedQuery->shouldReceive('orWhere')
                    ->once()
                    ->with('specialties.specialty', 'ILIKE', '%cardio%')
                    ->andReturnSelf();

                $filter($nestedQuery);

                return true;
            }))
            ->andReturnSelf();
        $query->shouldReceive('orderBy')->once()->with('users.name')->andReturnSelf();
        $query->shouldReceive('limit')->once()->with(16)->andReturnSelf();
        $query->shouldReceive('get')->once()->andReturn($results);

        $this->assertSame($results, (new SearchRepository)->searchDoctors('cardio'));
    }
}
