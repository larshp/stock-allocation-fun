CLASS zcl_stock_allocation_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_run_result,
             allocations TYPE zcl_stock_allocator=>ty_result_tt,
             posting     TYPE zif_allocation_poster=>ty_posting_result,
           END OF ty_run_result.

    METHODS constructor
      IMPORTING
        io_stock_reader       TYPE REF TO zif_stock_reader OPTIONAL
        io_requirement_reader TYPE REF TO zif_requirement_reader OPTIONAL
        io_writer             TYPE REF TO zif_allocation_writer OPTIONAL
        io_poster             TYPE REF TO zif_allocation_poster OPTIONAL
        io_uom_converter      TYPE REF TO zif_uom_converter OPTIONAL
        io_safety_stock       TYPE REF TO zif_safety_stock OPTIONAL
        io_substitution       TYPE REF TO zcl_stock_substitution OPTIONAL
        io_commitment         TYPE REF TO zcl_stock_commitment OPTIONAL
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

    METHODS allocate_with_substitution
      IMPORTING
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS commit_allocations
      IMPORTING
        iv_run_id         TYPE zstock_run_id
        iv_matnr          TYPE matnr
        iv_werks          TYPE werks_d
        it_result         TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rv_written) TYPE i.

    METHODS run_with_commitment
      IMPORTING
        iv_run_id        TYPE zstock_run_id
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS run_post_and_commit
      IMPORTING
        iv_run_id     TYPE zstock_run_id
        iv_matnr      TYPE matnr
        iv_werks      TYPE werks_d
        iv_move_type  TYPE bapi2017_gm_item_create-move_type DEFAULT '601'
      RETURNING
        VALUE(rs_run) TYPE ty_run_result.

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

    METHODS post_allocation
      IMPORTING
        it_result         TYPE zcl_stock_allocator=>ty_result_tt
        iv_matnr          TYPE matnr
        iv_werks          TYPE werks_d
        iv_move_type      TYPE bapi2017_gm_item_create-move_type DEFAULT '601'
      RETURNING
        VALUE(rs_posting) TYPE zif_allocation_poster=>ty_posting_result.

    METHODS run_with_posting
      IMPORTING
        iv_run_id     TYPE zstock_run_id
        iv_matnr      TYPE matnr
        iv_werks      TYPE werks_d
        iv_move_type  TYPE bapi2017_gm_item_create-move_type DEFAULT '601'
      RETURNING
        VALUE(rs_run) TYPE ty_run_result.

  PRIVATE SECTION.
    DATA mo_stock_reader       TYPE REF TO zif_stock_reader.
    DATA mo_requirement_reader TYPE REF TO zif_requirement_reader.
    DATA mo_writer             TYPE REF TO zif_allocation_writer.
    DATA mo_poster             TYPE REF TO zif_allocation_poster.
    DATA mo_uom_converter      TYPE REF TO zif_uom_converter.
    DATA mo_safety_stock       TYPE REF TO zif_safety_stock.
    DATA mo_substitution       TYPE REF TO zcl_stock_substitution.
    DATA mo_commitment         TYPE REF TO zcl_stock_commitment.
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

    IF io_poster IS SUPPLIED.
      mo_poster = io_poster.
    ENDIF.
    IF mo_poster IS NOT BOUND.
      mo_poster = NEW zcl_allocation_poster_bapi( ).
    ENDIF.

    IF io_uom_converter IS SUPPLIED.
      mo_uom_converter = io_uom_converter.
    ENDIF.
    IF mo_uom_converter IS NOT BOUND.
      mo_uom_converter = NEW zcl_uom_converter( ).
    ENDIF.

    IF io_safety_stock IS SUPPLIED.
      mo_safety_stock = io_safety_stock.
    ENDIF.
    IF mo_safety_stock IS NOT BOUND.
      mo_safety_stock = NEW zcl_safety_stock( ).
    ENDIF.

    IF io_substitution IS SUPPLIED.
      mo_substitution = io_substitution.
    ENDIF.
    IF mo_substitution IS NOT BOUND.
      mo_substitution = NEW zcl_stock_substitution(
        io_stock_reader = mo_stock_reader
        io_safety_stock = mo_safety_stock ).
    ENDIF.

    IF io_commitment IS SUPPLIED.
      mo_commitment = io_commitment.
    ENDIF.
    IF mo_commitment IS NOT BOUND.
      mo_commitment = NEW zcl_stock_commitment( ).
    ENDIF.


    mo_allocator = create_allocator( is_policy ).
  ENDMETHOD.

  METHOD create_allocator.
    IF is_policy IS SUPPLIED.
      ro_allocator = NEW #( io_stock_reader  = mo_stock_reader
                            io_uom_converter = mo_uom_converter
                            io_safety_stock  = mo_safety_stock
                            is_policy        = is_policy ).
    ELSE.
      ro_allocator = NEW #( io_stock_reader  = mo_stock_reader
                            io_uom_converter = mo_uom_converter
                            io_safety_stock  = mo_safety_stock ).
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

  METHOD allocate_with_substitution.
    DATA lt_requirements TYPE zif_requirement_reader=>ty_requirement_tt.
    DATA lt_materials    TYPE zcl_stock_allocator=>ty_material_tt.

    lt_requirements = mo_requirement_reader->read_requirements(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    APPEND iv_matnr TO lt_materials.

    LOOP AT mo_substitution->read_substitutes( iv_matnr )
        INTO DATA(ls_substitute).
      APPEND ls_substitute-submatnr TO lt_materials.
    ENDLOOP.

    rt_result = mo_allocator->allocate_materials(
      iv_matnr        = iv_matnr
      iv_werks        = iv_werks
      it_materials    = lt_materials
      it_requirements = lt_requirements ).
  ENDMETHOD.

  METHOD available_quantity.
    rv_quantity = mo_allocator->available_quantity( iv_matnr = iv_matnr
                                                    iv_werks = iv_werks ).
  ENDMETHOD.

  METHOD commit_allocations.
    rv_written = mo_commitment->commit( iv_run_id = iv_run_id
                                        iv_matnr  = iv_matnr
                                        iv_werks  = iv_werks
                                        it_result = it_result ).
  ENDMETHOD.

  METHOD run_with_commitment.
    rt_result = allocate( iv_matnr = iv_matnr
                          iv_werks = iv_werks ).

    mo_commitment->commit( iv_run_id = iv_run_id
                           iv_matnr  = iv_matnr
                           iv_werks  = iv_werks
                           it_result = rt_result ).

    mo_writer->write( iv_run_id = iv_run_id
                      iv_matnr  = iv_matnr
                      iv_werks  = iv_werks
                      it_result = rt_result ).
  ENDMETHOD.

  METHOD total_shortage.
    LOOP AT it_result INTO DATA(ls_result).
      rv_shortage = rv_shortage + ls_result-shortage_qty.
    ENDLOOP.
  ENDMETHOD.

  METHOD post_allocation.
    rs_posting = mo_poster->post( it_result    = it_result
                                  iv_matnr     = iv_matnr
                                  iv_werks     = iv_werks
                                  iv_move_type = iv_move_type ).
  ENDMETHOD.

  METHOD run_post_and_commit.
    rs_run-allocations = allocate( iv_matnr = iv_matnr
                                   iv_werks = iv_werks ).

    mo_commitment->commit( iv_run_id = iv_run_id
                           iv_matnr  = iv_matnr
                           iv_werks  = iv_werks
                           it_result = rs_run-allocations ).

    rs_run-posting = post_allocation( it_result    = rs_run-allocations
                                      iv_matnr     = iv_matnr
                                      iv_werks     = iv_werks
                                      iv_move_type = iv_move_type ).

    IF rs_run-posting-success = abap_true.
      " the goods issue already reduced the stock, keeping the commitment
      " would count the same quantity twice
      mo_commitment->release_run( iv_run_id ).
    ENDIF.

    mo_writer->write( iv_run_id = iv_run_id
                      iv_matnr  = iv_matnr
                      iv_werks  = iv_werks
                      it_result = rs_run-allocations ).
  ENDMETHOD.

  METHOD run_with_posting.
    rs_run-allocations = allocate( iv_matnr = iv_matnr
                                   iv_werks = iv_werks ).

    rs_run-posting = post_allocation( it_result    = rs_run-allocations
                                      iv_matnr     = iv_matnr
                                      iv_werks     = iv_werks
                                      iv_move_type = iv_move_type ).

    mo_writer->write( iv_run_id = iv_run_id
                      iv_matnr  = iv_matnr
                      iv_werks  = iv_werks
                      it_result = rs_run-allocations ).
  ENDMETHOD.

ENDCLASS.
