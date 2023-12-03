<?php

namespace App\Http\Controllers\Api\Forum;

use App\Http\Controllers\Controller;
use App\Services\ResearchService;
use Illuminate\Http\Request;

class ResearchController extends Controller
{
    protected $researchService;
    public function __construct(
        ResearchService $researchService
    ) {
        $this->researchService = $researchService;
    }
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index(Request $request)
    {
        $researchs = $this->researchService->getResearchs($request->all());

        return response()->json([
            'researchs' => $researchs
        ], 200);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $research = $this->researchService->create($request->all());
        return response()->json([
           'research' => $research,
           'message' => 'Create successfully'
        ], 200);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        $research = $this->researchService->find($id);
        return response()->json([
         'research' => $research
        ], 200);
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function edit($id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        $this->researchService->update($id, $request->all());
        
        return response()->json([
           'message' => 'Update successfully'
        ]);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        $this->researchService->delete($id);
        return response()->json([
            'message' => 'Delete successfully'
        ], 200);
    }
}
