<?php

use Illuminate\Foundation\Http\FormRequest;

class AvailableUsersRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'search' => ['nullable', 'string', 'max:100'],
        ];
    }
}