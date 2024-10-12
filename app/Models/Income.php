<?php

namespace App\Models;

use App\Models\Builders\IncomeBuilder;
use Database\Factories\IncomeFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Income extends Model
{
    /** @use HasFactory<IncomeFactory> */
    use HasFactory;

    protected $fillable = [
        'user_id', 'name',
    ];

    public function newEloquentBuilder($query): IncomeBuilder
    {
        return new IncomeBuilder($query);
    }
}