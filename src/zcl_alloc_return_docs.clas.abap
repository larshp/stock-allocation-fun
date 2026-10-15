CLASS zcl_alloc_return_docs DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_doc,
             doc_type TYPE string,
             doc_no   TYPE string,
           END OF ty_doc.
    TYPES ty_doc_tt TYPE STANDARD TABLE OF ty_doc WITH DEFAULT KEY.

    METHODS list
      IMPORTING
        it_docs        TYPE ty_doc_tt
        iv_type        TYPE string
      RETURNING
        VALUE(rt_docs) TYPE ty_doc_tt.

    METHODS count
      IMPORTING
        it_docs         TYPE ty_doc_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS by_type
      IMPORTING
        it_docs         TYPE ty_doc_tt
        iv_type         TYPE string
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_docs IMPLEMENTATION.

  METHOD list.
    " An empty type asks for every document.
    LOOP AT it_docs INTO DATA(ls_doc).
      IF iv_type IS NOT INITIAL AND ls_doc-doc_type <> iv_type.
        CONTINUE.
      ENDIF.

      APPEND ls_doc TO rt_docs.
    ENDLOOP.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( it_docs ).
  ENDMETHOD.

  METHOD by_type.
    LOOP AT it_docs INTO DATA(ls_doc).
      IF ls_doc-doc_type = iv_type.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
