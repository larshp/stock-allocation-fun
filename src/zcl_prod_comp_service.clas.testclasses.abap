CLASS lcl_prod_comp_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_prod_comp_repo.
    METHODS set_components
      IMPORTING
        it_components TYPE zif_prod_comp_repo=>ty_reservation_items.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA mt_components TYPE zif_prod_comp_repo=>ty_reservation_items.
    DATA mv_read_count TYPE i.
ENDCLASS.

CLASS lcl_prod_comp_repo IMPLEMENTATION.
  METHOD set_components.
    mt_components = it_components.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD zif_prod_comp_repo~get_components.
    ADD 1 TO mv_read_count.
    rt_items = mt_components.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_prod_reservation_reader DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_so_reservation_reader.
    METHODS set_result
      IMPORTING
        is_result TYPE zif_so_reservation_reader=>ty_result.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA ms_result TYPE zif_so_reservation_reader=>ty_result.
    DATA mv_read_count TYPE i.
ENDCLASS.

CLASS lcl_prod_reservation_reader IMPLEMENTATION.
  METHOD set_result.
    ms_result = is_result.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD zif_so_reservation_reader~read_reservation.
    ADD 1 TO mv_read_count.
    rs_result = ms_result.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_prod_goods_movement_api DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_goods_movement_api.
    METHODS get_items
      RETURNING
        VALUE(rt_items) TYPE zif_goods_movement_api=>ty_items.
    METHODS get_gm_code
      RETURNING
        VALUE(rv_gm_code) TYPE zif_goods_movement_api=>ty_gm_code.
    METHODS get_create_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_commit_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA mt_items TYPE zif_goods_movement_api=>ty_items.
    DATA mv_gm_code TYPE zif_goods_movement_api=>ty_gm_code.
    DATA mv_create_count TYPE i.
    DATA mv_commit_count TYPE i.
ENDCLASS.

CLASS lcl_prod_goods_movement_api IMPLEMENTATION.
  METHOD get_items.
    rt_items = mt_items.
  ENDMETHOD.

  METHOD get_gm_code.
    rv_gm_code = mv_gm_code.
  ENDMETHOD.

  METHOD get_create_count.
    rv_count = mv_create_count.
  ENDMETHOD.

  METHOD get_commit_count.
    rv_count = mv_commit_count.
  ENDMETHOD.

  METHOD zif_goods_movement_api~create_movement.
    ADD 1 TO mv_create_count.
    mt_items = it_items.
    mv_gm_code = iv_gm_code.
    rs_result = VALUE #(
      material_document = '4900000001'
      fiscal_year       = '2026'
      is_successful     = abap_true ).
  ENDMETHOD.

  METHOD zif_goods_movement_api~cancel_movement.
    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD zif_goods_movement_api~commit.
    ADD 1 TO mv_commit_count.
    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD zif_goods_movement_api~rollback.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_prod_comp_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS reads_open_components FOR TESTING.
    METHODS rejects_blank_order FOR TESTING.
    METHODS issues_selected_components FOR TESTING.
    METHODS rejects_unassigned_item FOR TESTING.
    METHODS rejects_component_over_issue FOR TESTING.
ENDCLASS.

CLASS ltcl_prod_comp_service IMPLEMENTATION.
  METHOD reads_open_components.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    lo_repository->set_components(
      it_components = VALUE #(
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0030'
          material           = 'MAT-2'
          plant              = '1000'
          movement_type      = '261'
          required_quantity  = '5.000'
          withdrawn_quantity = '1.000'
          unit               = 'EA' )
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0020'
          material           = 'MAT-1'
          plant              = '1000'
          required_quantity  = '4.000'
          withdrawn_quantity = '4.000'
          unit               = 'EA' )
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0010'
          material           = 'MAT-1'
          plant              = '1000'
          storage_location   = '0001'
          batch              = 'BATCH-1'
          movement_type      = '261'
          required_date      = '20261001'
          required_quantity  = '10.000'
          withdrawn_quantity = '3.000'
          unit               = 'EA' )
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0040'
          material           = 'MAT-3'
          plant              = '1000'
          required_quantity  = '8.000'
          withdrawn_quantity = '2.000'
          is_deleted         = 'X'
          unit               = 'EA' )
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0050'
          material           = 'MAT-4'
          plant              = '1000'
          required_quantity  = '8.000'
          withdrawn_quantity = '2.000'
          is_final_issue     = 'X'
          unit               = 'EA' )
        ( production_order   = '0000009999'
          reservation_number = '0000001234'
          reservation_item   = '0060'
          material           = 'MAT-5'
          plant              = '1000'
          required_quantity  = '8.000'
          withdrawn_quantity = '2.000'
          unit               = 'EA' )
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0070'
          material           = 'MAT-6'
          plant              = '1000'
          required_quantity  = '2.000'
          withdrawn_quantity = '3.000'
          unit               = 'EA' ) ) ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository = lo_repository ).

    DATA(lt_components) = lo_cut->get_open_components(
      iv_production_order = '0000004711' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_components ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010'
      act = lt_components[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-1'
      act = lt_components[ 1 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_components[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-1'
      act = lt_components[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '10.000' )
      act = lt_components[ 1 ]-required_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-enmng( '3.000' )
      act = lt_components[ 1 ]-withdrawn_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '7.000' )
      act = lt_components[ 1 ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0030'
      act = lt_components[ 2 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '4.000' )
      act = lt_components[ 2 ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_blank_order.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository = lo_repository ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_open_components( iv_production_order = space ).
      CATCH zcx_invalid_production_order.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD issues_selected_components.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    lo_repository->set_components(
      it_components = VALUE #(
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0010'
          material           = 'MAT-1'
          plant              = '1000'
          storage_location   = '0001'
          movement_type      = '261'
          required_quantity  = '10.000'
          withdrawn_quantity = '2.000'
          unit               = 'EA' ) ) ).
    DATA(lo_reader) = NEW lcl_prod_reservation_reader( ).
    lo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '0000001234'
            item_number        = '0010'
            record_type        = '1'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            plant              = '1000'
            storage_location   = '0001'
            required_quantity  = '10.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA'
            withdrawn_quantity = '2.000' ) ) ) ).
    DATA(lo_api) = NEW lcl_prod_goods_movement_api( ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository         = lo_repository
      io_reservation_reader = lo_reader
      io_goods_movement_api = lo_api ).

    DATA(ls_result) = lo_cut->issue_components(
      iv_production_order = '0000004711'
      is_header           = VALUE #(
        posting_date  = '20261001'
        document_date = '20261001' )
      it_requests         = VALUE #(
        ( reservation_number = '0000001234'
          reservation_item   = '0010'
          quantity           = '4.000' ) ) ).
    DATA(lt_items) = lo_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '03'
      act = lo_api->get_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = lt_items[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010'
      act = lt_items[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = space
      act = lt_items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_unassigned_item.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    lo_repository->set_components(
      it_components = VALUE #(
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0010'
          required_quantity  = '10.000'
          withdrawn_quantity = '2.000' ) ) ).
    DATA(lo_reader) = NEW lcl_prod_reservation_reader( ).
    DATA(lo_api) = NEW lcl_prod_goods_movement_api( ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository         = lo_repository
      io_reservation_reader = lo_reader
      io_goods_movement_api = lo_api ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->issue_components(
          iv_production_order = '0000004711'
          is_header           = VALUE #(
            posting_date  = '20261001'
            document_date = '20261001' )
          it_requests         = VALUE #(
            ( reservation_number = '0000001234'
              reservation_item   = '0099'
              quantity           = '1.000' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_component_over_issue.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    lo_repository->set_components(
      it_components = VALUE #(
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0010'
          required_quantity  = '10.000'
          withdrawn_quantity = '2.000' ) ) ).
    DATA(lo_reader) = NEW lcl_prod_reservation_reader( ).
    DATA(lo_api) = NEW lcl_prod_goods_movement_api( ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository         = lo_repository
      io_reservation_reader = lo_reader
      io_goods_movement_api = lo_api ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->issue_components(
          iv_production_order = '0000004711'
          is_header           = VALUE #(
            posting_date  = '20261001'
            document_date = '20261001' )
          it_requests         = VALUE #(
            ( reservation_number = '0000001234'
              reservation_item   = '0010'
              quantity           = '9.000' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.
ENDCLASS.
