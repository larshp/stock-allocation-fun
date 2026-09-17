CLASS zcl_stock_allocator DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES ty_order_id TYPE c LENGTH 10.
    TYPES ty_item_id TYPE n LENGTH 6.
    TYPES ty_locations TYPE STANDARD TABLE OF mard-lgort WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_requirement,
             order_id TYPE ty_order_id,
             item_id  TYPE ty_item_id,
             quantity TYPE mard-labst,
             priority TYPE i,
             due_date TYPE d,
           END OF ty_requirement.
    TYPES ty_requirements TYPE STANDARD TABLE OF ty_requirement WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_pick,
             order_id TYPE ty_order_id,
             item_id  TYPE ty_item_id,
             material TYPE mard-matnr,
             plant    TYPE mard-werks,
             location TYPE mard-lgort,
             quantity TYPE mard-labst,
           END OF ty_pick.
    TYPES ty_picks TYPE STANDARD TABLE OF ty_pick WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_result,
             requirement TYPE ty_requirement,
             allocated   TYPE mard-labst,
             shortage    TYPE mard-labst,
             deferred    TYPE abap_bool,
           END OF ty_result.
    TYPES ty_results TYPE STANDARD TABLE OF ty_result WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_plan,
             picks   TYPE ty_picks,
             results TYPE ty_results,
           END OF ty_plan.
    TYPES: BEGIN OF ty_shortage,
             order_id TYPE ty_order_id,
             item_id  TYPE ty_item_id,
             quantity TYPE mard-labst,
           END OF ty_shortage.
    TYPES ty_shortages TYPE STANDARD TABLE OF ty_shortage WITH DEFAULT KEY.
    TYPES ty_total TYPE p LENGTH 16 DECIMALS 3.
    TYPES: BEGIN OF ty_summary,
             total_requested TYPE ty_total,
             total_allocated TYPE ty_total,
             total_shortage  TYPE ty_total,
             shortages       TYPE ty_shortages,
           END OF ty_summary.
    CLASS-METHODS summarize
      IMPORTING is_plan           TYPE ty_plan
      RETURNING VALUE(rs_summary) TYPE ty_summary.
    CLASS-METHODS allocate
      IMPORTING iv_available_qty   TYPE mard-labst
                iv_requested_qty   TYPE mard-labst
      RETURNING VALUE(rv_quantity) TYPE mard-labst.
    CLASS-METHODS plan
      IMPORTING it_stock         TYPE zif_stock_reader=>ty_stock_tt
                it_requirements  TYPE ty_requirements
                iv_material      TYPE mard-matnr
                iv_plant         TYPE mard-werks
                iv_safety_stock  TYPE mard-labst DEFAULT 0
                iv_full_delivery TYPE abap_bool DEFAULT abap_false
                iv_horizon       TYPE d OPTIONAL
                it_locations     TYPE ty_locations OPTIONAL
      RETURNING VALUE(rs_plan)   TYPE ty_plan.
ENDCLASS.

CLASS zcl_stock_allocator IMPLEMENTATION.
  METHOD allocate.
    IF iv_available_qty <= 0 OR iv_requested_qty <= 0.
      rv_quantity = 0.
    ELSEIF iv_available_qty < iv_requested_qty.
      rv_quantity = iv_available_qty.
    ELSE.
      rv_quantity = iv_requested_qty.
    ENDIF.
  ENDMETHOD.

  METHOD plan.
    DATA stock TYPE zif_stock_reader=>ty_stock_tt.
    DATA available TYPE mard-labst.
    DATA reserve TYPE mard-labst.
    DATA taken TYPE mard-labst.
    DATA remaining TYPE mard-labst.
    DATA result TYPE ty_result.
    IF iv_material IS INITIAL OR iv_plant IS INITIAL.
      RETURN.
    ENDIF.
    stock = it_stock.
    DELETE stock WHERE matnr <> iv_material OR werks <> iv_plant OR labst <= 0 OR mandt <> sy-mandt.
    IF it_locations IS NOT INITIAL.
      LOOP AT stock INTO DATA(candidate).
        DATA(stock_index) = sy-tabix.
        READ TABLE it_locations WITH KEY table_line = candidate-lgort TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          DELETE stock INDEX stock_index.
        ENDIF.
      ENDLOOP.
    ENDIF.
    SORT stock BY lgort.
    reserve = iv_safety_stock.
    LOOP AT stock ASSIGNING FIELD-SYMBOL(<stock>).
      taken = allocate( iv_available_qty = <stock>-labst iv_requested_qty = reserve ).
      <stock>-labst = <stock>-labst - taken.
      reserve = reserve - taken.
      available = available + <stock>-labst.
    ENDLOOP.
    DATA(requirements) = it_requirements.
    SORT requirements STABLE BY priority due_date order_id item_id.
    LOOP AT requirements INTO DATA(requirement).
      CLEAR result.
      result-requirement = requirement.
      remaining = requirement-quantity.
      IF remaining <= 0.
        APPEND result TO rs_plan-results.
        CONTINUE.
      ENDIF.
      result-shortage = remaining.
      IF iv_horizon IS NOT INITIAL AND requirement-due_date > iv_horizon.
        result-deferred = abap_true.
        APPEND result TO rs_plan-results.
        CONTINUE.
      ENDIF.
      IF iv_full_delivery = abap_true AND remaining > available.
        APPEND result TO rs_plan-results.
        CONTINUE.
      ENDIF.
      LOOP AT stock ASSIGNING <stock> WHERE labst > 0.
        taken = allocate( iv_available_qty = <stock>-labst iv_requested_qty = remaining ).
        IF taken <= 0.
          EXIT.
        ENDIF.
        APPEND VALUE #( order_id = requirement-order_id item_id = requirement-item_id
                        material = iv_material plant = iv_plant location = <stock>-lgort
                        quantity = taken ) TO rs_plan-picks.
        <stock>-labst = <stock>-labst - taken.
        available = available - taken.
        remaining = remaining - taken.
        result-allocated = result-allocated + taken.
      ENDLOOP.
      result-shortage = remaining.
      APPEND result TO rs_plan-results.
    ENDLOOP.
  ENDMETHOD.

  METHOD summarize.
    LOOP AT is_plan-results INTO DATA(result).
      IF result-requirement-quantity > 0.
        rs_summary-total_requested = rs_summary-total_requested + result-requirement-quantity.
      ENDIF.
      rs_summary-total_allocated = rs_summary-total_allocated + result-allocated.
      rs_summary-total_shortage = rs_summary-total_shortage + result-shortage.
      IF result-shortage > 0.
        APPEND VALUE #( order_id = result-requirement-order_id item_id = result-requirement-item_id
                        quantity = result-shortage ) TO rs_summary-shortages.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
