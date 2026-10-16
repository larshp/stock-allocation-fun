CLASS ltcl_alloc_return_docs DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_docs.
    DATA mt_doc TYPE zcl_alloc_return_docs=>ty_doc_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_type TYPE string
        iv_no   TYPE string.

    METHODS lists_by_type FOR TESTING.
    METHODS lists_all     FOR TESTING.
    METHODS counts_all    FOR TESTING.
    METHODS counts_type   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_docs IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_docs( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_doc TYPE zcl_alloc_return_docs=>ty_doc.

    ls_doc-doc_type = iv_type.
    ls_doc-doc_no = iv_no.
    APPEND ls_doc TO mt_doc.
  ENDMETHOD.

  METHOD lists_by_type.
    DATA lt_docs TYPE zcl_alloc_return_docs=>ty_doc_tt.

    add( iv_type = 'RMA' iv_no = 'R1' ).
    add( iv_type = 'CREDIT' iv_no = 'C1' ).
    add( iv_type = 'RMA' iv_no = 'R2' ).

    lt_docs = mo_cut->list( it_docs = mt_doc iv_type = 'RMA' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_docs ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_docs[ 1 ]-doc_no exp = 'R1' ).
  ENDMETHOD.

  METHOD lists_all.
    DATA lt_docs TYPE zcl_alloc_return_docs=>ty_doc_tt.

    add( iv_type = 'RMA' iv_no = 'R1' ).
    add( iv_type = 'CREDIT' iv_no = 'C1' ).

    lt_docs = mo_cut->list( it_docs = mt_doc iv_type = '' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_docs ) exp = 2 ).
  ENDMETHOD.

  METHOD counts_all.
    add( iv_type = 'RMA' iv_no = 'R1' ).
    add( iv_type = 'CREDIT' iv_no = 'C1' ).
    add( iv_type = 'RMA' iv_no = 'R2' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count( mt_doc ) exp = 3 ).
  ENDMETHOD.

  METHOD counts_type.
    add( iv_type = 'RMA' iv_no = 'R1' ).
    add( iv_type = 'CREDIT' iv_no = 'C1' ).
    add( iv_type = 'RMA' iv_no = 'R2' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->by_type( it_docs = mt_doc iv_type = 'RMA' ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->by_type( it_docs = mt_doc iv_type = 'CREDIT' ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
