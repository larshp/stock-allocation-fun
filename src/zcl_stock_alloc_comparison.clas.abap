CLASS zcl_stock_alloc_comparison DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_comparison,
             request_id       TYPE c LENGTH 32,
             material         TYPE c LENGTH 18,
             plant            TYPE c LENGTH 4,
             storage          TYPE c LENGTH 4,
             unit             TYPE c LENGTH 3,
             required_date    TYPE d,
             requested        TYPE zif_stock_alloc_types=>ty_quantity,
             origin           TYPE zif_stock_alloc_types=>ty_origin,
             allocated_before TYPE zif_stock_alloc_types=>ty_quantity,
             allocated_after  TYPE zif_stock_alloc_types=>ty_quantity,
             shortage_before  TYPE zif_stock_alloc_types=>ty_quantity,
             shortage_after   TYPE zif_stock_alloc_types=>ty_quantity,
             allocation_delta TYPE zif_stock_alloc_types=>ty_quantity,
             change           TYPE c LENGTH 10,
           END OF ty_comparison.
    TYPES ty_comparisons TYPE STANDARD TABLE OF ty_comparison WITH DEFAULT KEY.
    CONSTANTS: change_improved TYPE c LENGTH 10 VALUE 'IMPROVED',
               change_reduced  TYPE c LENGTH 10 VALUE 'REDUCED',
               change_unchanged TYPE c LENGTH 10 VALUE 'UNCHANGED'.
    METHODS compare
      IMPORTING baseline           TYPE zif_stock_alloc_types=>ty_allocations
                scenario           TYPE zif_stock_alloc_types=>ty_allocations
      RETURNING VALUE(comparisons) TYPE ty_comparisons
      RAISING zcx_stock_alloc.
ENDCLASS.

CLASS zcl_stock_alloc_comparison IMPLEMENTATION.
  METHOD compare.
    zcl_stock_alloc_result=>validate( baseline ).
    zcl_stock_alloc_result=>validate( scenario ).
    IF lines( baseline ) <> lines( scenario ).
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'Comparison requires the same demand in both runs'.
    ENDIF.
    DATA indexed TYPE HASHED TABLE OF zif_stock_alloc_types=>ty_allocation WITH UNIQUE KEY request_id.
    indexed = scenario.
    LOOP AT baseline INTO DATA(before).
      READ TABLE indexed INTO DATA(after) WITH TABLE KEY request_id = before-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = |Scenario is missing request { before-request_id }|.
      ENDIF.
      IF before-material <> after-material OR before-plant <> after-plant
          OR before-storage <> after-storage OR before-unit <> after-unit
          OR before-required_date <> after-required_date OR before-requested <> after-requested
          OR before-origin <> after-origin.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = |Demand differs for request { before-request_id }|.
      ENDIF.
      DATA(row) = VALUE ty_comparison(
        request_id       = before-request_id
        material         = before-material
        plant            = before-plant
        storage          = before-storage
        unit             = before-unit
        required_date    = before-required_date
        requested        = before-requested
        origin           = before-origin
        allocated_before = before-allocated
        allocated_after  = after-allocated
        shortage_before  = before-shortage
        shortage_after   = after-shortage
        allocation_delta = after-allocated - before-allocated
        change           = change_unchanged ).
      IF row-allocation_delta > 0.
        row-change = change_improved.
      ELSEIF row-allocation_delta < 0.
        row-change = change_reduced.
      ENDIF.
      APPEND row TO comparisons.
    ENDLOOP.
    SORT comparisons BY request_id.
  ENDMETHOD.
ENDCLASS.
