<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\SearchService;

class SearchController extends Controller
{
    public function __construct(private SearchService $service)
    {
    }

    public function index(Request $request)
    {
        $query = trim($request->query('q', ''));

        return response()->json(
            $this->service->search($query)
        );
    }
}