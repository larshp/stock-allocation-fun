CLASS zcl_stock_source_adjusted DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_source.
    METHODS constructor
      IMPORTING source      TYPE REF TO zif_stock_source
                adjustments TYPE zif_stock_alloc_types=>ty_stocks
      RAISING   zcx_stock_alloc.
  PRIVATE SECTION.
    DATA source TYPE REF TO zif_stock_source.
    DATA adjustments TYPE HASHED TABLE OF zif_stock_alloc_types=>ty_stock
      WITH UNIQUE KEY material plant storage.
ENDCLASS.

CLASS zcl_stock_source_adjusted IMPLEMENTATION.
  METHOD constructor.
    IF source IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'An underlying stock source is required'.
    ENDIF.
    DATA(validator) = NEW zcl_stock_allocator( ).
    validator->validate( stocks   = adjustments
                         requests = VALUE #( ) ).
    LOOP AT adjustments INTO DATA(adjustment).
      IF adjustment-quantity <> 0.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = 'Adjustments contain only safety stock and committed quantity'.
      ENDIF.
    ENDLOOP.
    me->source = source.
    me->adjustments = adjustments.
  ENDMETHOD.

  METHOD zif_stock_source~read.
    stocks = source->read( requests ).
    LOOP AT stocks ASSIGNING FIELD-SYMBOL(<stock>).
      READ TABLE adjustments INTO DATA(adjustment)
        WITH TABLE KEY material = <stock>-material
                       plant    = <stock>-plant
                       storage  = <stock>-storage.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      IF adjustment-unit <> <stock>-unit.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = |Adjustment unit mismatch for material { <stock>-material }|.
      ENDIF.
      IF <stock>-safety_stock <> 0 OR <stock>-committed <> 0.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = 'Stock source already contains adjustments'.
      ENDIF.
      <stock>-safety_stock = adjustment-safety_stock.
      <stock>-committed = adjustment-committed.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
