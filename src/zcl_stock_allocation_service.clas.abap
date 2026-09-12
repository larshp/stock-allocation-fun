CLASS zcl_stock_allocation_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_stock_reader       TYPE REF TO zif_stock_reader OPTIONAL
        io_requirement_reader TYPE REF TO zif_requirement_reader OPTIONAL
        io_writer             TYPE REF TO zif_allocation_writer OPTIONAL
        is_policy             TYPE zcl_stock_allocator=>ty_policy OPTIONAL.

    METHODS allocate
      IMPORTING
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS allocate_and_record
      IMPORTING
        iv_run_id        TYPE zstock_run_id
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS allocate_for_requirements
      IMPORTING
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
        it_requirements  TYPE zif_requirement_reader=>ty_requirement_tt
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS available_quantity
      IMPORTING
        iv_matnr           TYPE matnr
        iv_werks           TYPE werks_d
      RETURNING
        VALUE(rv_quantity) TYPE zif_stock_reader=>ty_quantity.

    METHODS total_shortage
      IMPORTING
        it_result          TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rv_shortage) TYPE zif_stock_reader=>ty_quantity.

  PRIVATE SECTION.
    DATA mo_stock_reader       TYPE REF TO zif_stock_reader.
    DATA mo_requirement_reader TYPE REF TO zif_requirement_reader.
    DATA mo_writer             TYPE REF TO zif_allocation_writer.
    DATA mo_allocator          TYPE REF TO zcl_stock_allocator.

    METHODS create_allocator
      IMPORTING
        is_policy           TYPE zcl_stock_allocator=>ty_policy OPTIONAL
      RETURNING
        VALUE(ro_allocator) TYPE REF TO zcl_stock_allocator.

ENDCLASS.


CLASS zcl_stock_allocation_service IMPLEMENTATION.

  METHOD constructor.
    IF io_stock_reader IS SUPPLIED.
      mo_stock_reader = io_stock_reader.
    ENDIF.
    IF mo_stock_reader IS NOT BOUND.
      mo_stock_reader = NEW zcl_stock_reader_mard( ).
    ENDIF.

    IF io_requirement_reader IS SUPPLIED.
      mo_requirement_reader = io_requirement_reader.
    ENDIF.
    IF mo_requirement_reader IS NOT BOUND.
      mo_requirement_reader = NEW zcl_requirement_reader_resb( ).
    ENDIF.
IF io_writer IS SUPPLIED.
      mo_writer = io_writer.
    ENDIF.
    IF mo_writer IS NOT BOUND.
      mo_writer = NEW zcl_allocation_writer_db( ).
    ENDIF.

    
    mo_allocator = create_allocator( is_policy ).
  ENDMETHOD.

  METHOD create_allocator.
    IF is_policy IS SUPPLIED.
      ro_allocator = NEW #( io_stock_reader = mo_stock_reader
                            is_policy       = is_policy ).
    ELSE.
      ro_allocator = NEW #( io_stock_reader = mo_stock_reader ).
    ENDIF.
  ENDMETHOD.

  METHOD allocate.
    DATA lt_requirements TYPE zif_requirement_reader=>ty_requirement_tt.

    lt_requirements = mo_requirement_reader->read_requirements(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    rt_result = mo_allocator->allocate( iv_matnr        = iv_matnr
                                        iv_werks        = iv_werks
                                        it_requirements = lt_requirements ).
  ENDMETHOD.

  METHOD allocate_and_record.
    rt_result = allocate( iv_matnr = iv_matnr
                          iv_werks = iv_werks ).

    mo_writer->write( iv_run_id = iv_run_id
                      iv_matnr  = iv_matnr
                      iv_werks  = iv_werks
                      it_result = rt_result ).
  ENDMETHOD.

  METHOD allocate_for_requirements.
    rt_result = mo_allocator->allocate( iv_matnr        = iv_matnr
                                        iv_werks        = iv_werks
                                        it_requirements = it_requirements ).
  ENDMETHOD.

  METHOD available_quantity.
    rv_quantity = mo_allocator->available_quantity( iv_matnr = iv_matnr
                                                    iv_werks = iv_werks ).
  ENDMETHOD.

  METHOD total_shortage.
    LOOP AT it_result INTO DATA(ls_result).
      rv_shortage = rv_shortage + ls_result-shortage_qty.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
