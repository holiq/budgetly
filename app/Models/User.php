<?php

namespace App\Models;

use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable implements FilamentUser, MustVerifyEmail
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory;

    use Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * @return HasMany<Account>
     */
    public function accounts(): HasMany
    {
        return $this->hasMany(
            Account::class,
            'user_id'
        );

    }

    /**
     * @return HasMany<Expense>
     */
    public function expenses(): HasMany
    {
        return $this->hasMany(
            Expense::class,
            'user_id'
        );
    }

    /**
     * @return HasMany<Income>
     */
    public function incomes(): HasMany
    {
        return $this->hasMany(
            Income::class,
            'user_id'
        );
    }

    public function canAccessPanel(Panel $panel): bool
    {
        return true;
    }
}
