CLASS zcl_stock_alloc_summary DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_summary,
             material            TYPE c LENGTH 18,
             plant               TYPE c LENGTH 4,
             storage             TYPE c LENGTH 4,
             unit                TYPE c LENGTH 3,
             requested           TYPE zif_stock_alloc_types=>ty_quantity,
             allocated           TYPE zif_stock_alloc_types=>ty_quantity,
             shortage            TYPE zif_stock_alloc_types=>ty_quantity,
             request_count       TYPE i,
             full_count          TYPE i,
             partial_count       TYPE i,
             unfilled_count      TYPE i,
             first_shortage_date TYPE d,
           END OF ty_summary.
    TYPES ty_summaries TYPE STANDARD TABLE OF ty_summary WITH DEFAULT KEY.
    METHODS summarize
      IMPORTING allocations      TYPE zif_stock_alloc_types=>ty_allocations
      RETURNING VALUE(summaries) TYPE ty_summaries
      RAISING zcx_stock_alloc.
ENDCLASS.

CLASS zcl_stock_alloc_summary IMPLEMENTATION.
  METHOD summarize.
    zcl_stock_alloc_result=>validate( allocations ).
    DATA grouped TYPE HASHED TABLE OF ty_summary WITH UNIQUE KEY material plant storage unit.
    LOOP AT allocations INTO DATA(allocation).
      READ TABLE grouped ASSIGNING FIELD-SYMBOL(<summary>)
        WITH TABLE KEY material = allocation-material
                       plant = allocation-plant
                       storage = allocation-storage
                       unit = allocation-unit.
      IF sy-subrc <> 0.
        INSERT VALUE #( material = allocation-material
                        plant    = allocation-plant
                        storage  = allocation-storage
                        unit     = allocation-unit ) INTO TABLE grouped ASSIGNING <summary>.
      ENDIF.
      " Detect overflow before assigning back to the public quantity contract.
      DATA total_ticks TYPE p LENGTH 9 DECIMALS 0.
      DATA row_ticks TYPE p LENGTH 9 DECIMALS 0.
      total_ticks = <summary>-requested * 1000.
      row_ticks = allocation-requested * 1000.
      total_ticks = total_ticks + row_ticks.
      IF total_ticks > 9999999999999.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = 'Grouped requested quantity exceeds the supported quantity range'.
      ENDIF.
      <summary>-requested = total_ticks / 1000.
      <summary>-allocated = <summary>-allocated + allocation-allocated.
      <summary>-shortage = <summary>-requested - <summary>-allocated.
      <summary>-request_count = <summary>-request_count + 1.
      IF allocation-shortage = 0.
        <summary>-full_count = <summary>-full_count + 1.
      ELSE.
        IF allocation-allocated = 0.
          <summary>-unfilled_count = <summary>-unfilled_count + 1.
        ELSE.
          <summary>-partial_count = <summary>-partial_count + 1.
        ENDIF.
        IF <summary>-first_shortage_date IS INITIAL
            OR allocation-required_date < <summary>-first_shortage_date.
          <summary>-first_shortage_date = allocation-required_date.
        ENDIF.
      ENDIF.
    ENDLOOP.
    summaries = grouped.
    SORT summaries BY material plant storage unit.
  ENDMETHOD.
ENDCLASS.
