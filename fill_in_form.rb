require 'hexapdf'
require 'pry'

def retrieve_field(pdf, field_name)
  field_refs = pdf.pages.map { |p| p[:Annots] }.flatten
  fields = field_refs.map { |ref| pdf.object(ref) }
  fields.select { |f| f[:T] == field_name }[0]
end

# Fill in the form with a single-line value
single_name = "./singleline-form.pdf"
single_doc = HexaPDF::Document.open(single_name)

field = retrieve_field(single_doc, "verse")
field[:V] = "Dear sir, your astonishment's odd"

single_doc.catalog[:AcroForm][:NeedAppearances] = true

single_doc.task(:optimize, compact: true,
              object_streams: :delete)

single_filled_in = "./single-filled-in.pdf"
single_doc.write(single_filled_in)

# Fill in the form with a multi-line value
multi_name = "./multiline-form.pdf"
multi_doc = HexaPDF::Document.open(multi_name)

field = retrieve_field(multi_doc, "verse")
field[:V] = "Dear sir, your astonishment's odd"

multi_doc.catalog[:AcroForm][:NeedAppearances] = true

multi_doc.task(:optimize, compact: true,
              object_streams: :delete)

multi_filled_in = "./multi-filled-in.pdf"
multi_doc.write(multi_filled_in)

# Combine forms, starting with single-line, then multi-line
combined = HexaPDF::Document.new
[single_filled_in, multi_filled_in].each do |filename|
  pdf = HexaPDF::Document.open(filename)
  pdf.pages.each { |page| combined.pages << combined.import(page) }
end

(combined.catalog[:AcroForm] = {})[:NeedAppearances] = true

combined.task(:optimize, compact: true,
              object_streams: :delete)

combined_name = "./combined.pdf"
combined.write(combined_name)

# At which point, in Chrome or Acrobat, the second document,
# which is a multi-line form in its own document
# displays as a single-line field, vertically centered in the box,
# until it cuts short at the right edge of the box.
