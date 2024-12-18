<?php

namespace App\Filament\Resources\Budgeting\ExpenseResource\Pages;

use App\Filament\Resources\Budgeting\ExpenseResource;
use App\Models\Expense;
use Filament\Forms\Form;
use Filament\Resources\Pages\ViewRecord;

class ViewExpense extends ViewRecord
{
    protected static string $resource = ExpenseResource::class;

    public function getHeading(): string|\Illuminate\Contracts\Support\Htmlable
    {
        /** @var Expense $record */
        $record = $this->getRecord();

        return 'View Expenses of '.$record->name;
    }

    /**
     * @return array<int | string, string | Form>
     */
    protected function getForms(): array
    {
        return [
            'form' => $this->makeForm(),
        ];
    }
}
