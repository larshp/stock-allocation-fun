CLASS ltcl_alloc_recall_scope DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_recall_scope.
    DATA mt_sto TYPE zcl_alloc_recall_scope=>ty_stock_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_batch TYPE string
        iv_mat   TYPE matnr.

    METHODS material_scope FOR TESTING.
    METHODS batch_scope    FOR TESTING.
    METHODS unknown_batch  FOR TESTING.
    METHODS distinct_only  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_recall_scope IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_recall_scope( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_stock TYPE zcl_alloc_recall_scope=>ty_stock.

    ls_stock-batch = iv_batch.
    ls_stock-material = iv_mat.
    APPEND ls_stock TO mt_sto.
  ENDMETHOD.

  METHOD material_scope.
    DATA lt_mats TYPE zcl_alloc_recall_scope=>ty_text_tt.

    add( iv_batch = 'B001' iv_mat = 'M1' ).

    lt_mats = mo_cut->materials( it_stock = mt_sto iv_batch = 'B001' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_mats ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_mats[ 1 ] exp = 'M1' ).
  ENDMETHOD.

  METHOD batch_scope.
    DATA lt_batches TYPE zcl_alloc_recall_scope=>ty_text_tt.

    add( iv_batch = 'B001' iv_mat = 'M1' ).
    add( iv_batch = 'B002' iv_mat = 'M1' ).
    add( iv_batch = 'B003' iv_mat = 'M2' ).

    lt_batches = mo_cut->batches( it_stock = mt_sto iv_batch = 'B001' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_batches ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_batches[ 1 ] exp = 'B001' ).
    cl_abap_unit_assert=>assert_equals( act = lt_batches[ 2 ] exp = 'B002' ).
  ENDMETHOD.

  METHOD unknown_batch.
    DATA lt_batches TYPE zcl_alloc_recall_scope=>ty_text_tt.

    add( iv_batch = 'B001' iv_mat = 'M1' ).

    lt_batches = mo_cut->batches( it_stock = mt_sto iv_batch = 'B999' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_batches ) exp = 0 ).
  ENDMETHOD.

  METHOD distinct_only.
    DATA lt_batches TYPE zcl_alloc_recall_scope=>ty_text_tt.

    add( iv_batch = 'B001' iv_mat = 'M1' ).
    add( iv_batch = 'B001' iv_mat = 'M1' ).

    lt_batches = mo_cut->batches( it_stock = mt_sto iv_batch = 'B001' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_batches ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
