"! Allocation document - the persistent result of an allocation run.
"! One document (VBELN-like number) holds all allocation rows of a run and
"! its status: OPEN -> POSTED. Simulation runs are not saved.
CLASS zcl_alloc_document DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_doc_item,
             vbeln     TYPE vbap-vbeln,   " sales order
             posnr     TYPE vbap-posnr,   " item
             matnr     TYPE vbap-matnr,
             werks     TYPE vbap-werks,
             lgort     TYPE mard-lgort,
             qty_alloc TYPE kwmeng,
           END OF ty_doc_item.
    TYPES tt_doc_items TYPE STANDARD TABLE OF ty_doc_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_document,
             docnr  TYPE char10,          " allocation document number
             status TYPE char1,           " O = open, P = posted
             items  TYPE tt_doc_items,
           END OF ty_document.

    "! Create an allocation document from run allocations.
    "! Returns the generated document number.
    CLASS-METHODS create
      IMPORTING
        it_allocations  TYPE zcl_stock_allocator=>tt_allocations
      RETURNING
        VALUE(rv_docnr) TYPE char10.

    "! Read a stored document; initial structure if not found
    CLASS-METHODS read
      IMPORTING
        iv_docnr      TYPE char10
      RETURNING
        VALUE(rs_doc) TYPE ty_document.

    "! Mark a document as posted
    CLASS-METHODS set_posted
      IMPORTING
        iv_docnr TYPE char10.

    "! Test helper: clear all documents
    CLASS-METHODS clear.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA gt_documents TYPE STANDARD TABLE OF ty_document WITH DEFAULT KEY.
    CLASS-DATA gv_next_number TYPE n LENGTH 10.

ENDCLASS.



CLASS zcl_alloc_document IMPLEMENTATION.


  METHOD create.
    " generate next document number starting at 5000000001
    IF gv_next_number IS INITIAL.
      gv_next_number = '5000000000'.
    ENDIF.
    gv_next_number = gv_next_number + 1.

    DATA(ls_doc) = VALUE ty_document(
        docnr  = gv_next_number
        status = 'O' ).

    LOOP AT it_allocations INTO DATA(ls_alloc).
      APPEND VALUE ty_doc_item(
          vbeln     = ls_alloc-vbeln
          posnr     = ls_alloc-posnr
          matnr     = ls_alloc-matnr
          werks     = ls_alloc-werks
          lgort     = ls_alloc-lgort
          qty_alloc = ls_alloc-qty_alloc ) TO ls_doc-items.
    ENDLOOP.

    APPEND ls_doc TO gt_documents.
    rv_docnr = ls_doc-docnr.
  ENDMETHOD.


  METHOD read.
    READ TABLE gt_documents INTO rs_doc WITH KEY docnr = iv_docnr.
    IF sy-subrc <> 0.
      CLEAR rs_doc.
    ENDIF.
  ENDMETHOD.


  METHOD set_posted.
    READ TABLE gt_documents ASSIGNING FIELD-SYMBOL(<ls_doc>)
      WITH KEY docnr = iv_docnr.
    IF sy-subrc = 0.
      <ls_doc>-status = 'P'.
    ENDIF.
  ENDMETHOD.


  METHOD clear.
    CLEAR gt_documents.
    CLEAR gv_next_number.
  ENDMETHOD.


ENDCLASS.
