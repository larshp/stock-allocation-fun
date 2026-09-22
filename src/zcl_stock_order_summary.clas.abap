CLASS zcl_stock_order_summary DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_summary,
             order_id            TYPE c LENGTH 12,
             request_count       TYPE i,
             full_count          TYPE i,
             partial_count       TYPE i,
             unfilled_count      TYPE i,
             status              TYPE c LENGTH 10,
             first_shortage_date TYPE d,
             shortages           TYPE zif_stock_alloc_types=>ty_allocations,
           END OF ty_summary.
    TYPES ty_summaries TYPE STANDARD TABLE OF ty_summary WITH DEFAULT KEY.
    METHODS summarize
      IMPORTING allocations      TYPE zif_stock_alloc_types=>ty_allocations
      RETURNING VALUE(summaries) TYPE ty_summaries
      RAISING zcx_stock_alloc.
ENDCLASS.

CLASS zcl_stock_order_summary IMPLEMENTATION.
  METHOD summarize.
    zcl_stock_alloc_result=>validate( allocations ).
    DATA grouped TYPE HASHED TABLE OF ty_summary WITH UNIQUE KEY order_id.
    LOOP AT allocations INTO DATA(allocation).
      IF allocation-origin-order_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = |Order origin is required for request { allocation-request_id }|.
      ENDIF.
      READ TABLE grouped ASSIGNING FIELD-SYMBOL(<summary>)
        WITH TABLE KEY order_id = allocation-origin-order_id.
      IF sy-subrc <> 0.
        INSERT VALUE #( order_id = allocation-origin-order_id )
          INTO TABLE grouped ASSIGNING <summary>.
      ENDIF.
      <summary>-request_count = <summary>-request_count + 1.
      IF allocation-shortage = 0.
        <summary>-full_count = <summary>-full_count + 1.
      ELSE.
        APPEND allocation TO <summary>-shortages.
        IF allocation-allocated = 0.
          <summary>-unfilled_count = <summary>-unfilled_count + 1.
        ELSE.
          <summary>-partial_count = <summary>-partial_count + 1.
        ENDIF.
      ENDIF.
    ENDLOOP.
    LOOP AT grouped ASSIGNING <summary>.
      IF <summary>-full_count = <summary>-request_count.
        <summary>-status = zif_stock_alloc_types=>status_full.
      ELSE.
        IF <summary>-full_count > 0 OR <summary>-partial_count > 0.
          <summary>-status = zif_stock_alloc_types=>status_partial.
        ELSE.
          <summary>-status = zif_stock_alloc_types=>status_short.
        ENDIF.
        SORT <summary>-shortages BY required_date request_id.
        <summary>-first_shortage_date = <summary>-shortages[ 1 ]-required_date.
      ENDIF.
    ENDLOOP.
    summaries = grouped.
    SORT summaries BY order_id.
  ENDMETHOD.
ENDCLASS.
