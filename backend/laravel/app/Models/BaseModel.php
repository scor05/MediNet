<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * Shared base model annotations for editor/static-analysis support.
 *
 * @mixin Builder<static>
 * @method static Builder<static> query()
 * @method static Builder<static> newQuery()
 * @method static Builder<static> where($column, $operator = null, $value = null, $boolean = 'and')
 * @method static Builder<static> with($relations)
 * @method static Collection<int, static> all($columns = ['*'])
 * @method static static|null find($id, $columns = ['*'])
 * @method static static findOrFail($id, $columns = ['*'])
 * @method static static create(array $attributes = [])
 */
abstract class BaseModel extends Model
{
}
