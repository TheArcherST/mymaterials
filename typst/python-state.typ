// Printable counterpart of templates/components/python_state.html.
// Accepts the same frames/objects data from yaml(), json(), or a dictionary.
// Browser composition v1 is accepted unchanged (compact/verbose, object/JSON string).
#let entries(value) = {
  if type(value) == dictionary { value.pairs() }
  else {
    assert(type(value) == array, message: "Expected a dictionary or an array of entries")
    value.map(item => (item.id, item))
  }
}

#let literal(value, kind) = {
  if kind == "NoneType" or value == none { "None" }
  else if kind == "bool" { if value { "True" } else { "False" } }
  else if kind == "str" { json.encode(value) }
  else if kind == "list" { "[]" }
  else if kind == "dict" { "{}" }
  else if type(value) == str { value }
  else { repr(value) }
}

#let composition-points(value) = {
  if value == none { return (:) }
  let payload = if type(value) == str { json(bytes(value)) } else { value }
  payload = payload.at("composition", default: payload)
  let version = payload.at("schema_version", default: payload.at("v", default: 1))
  assert(version == 1, message: "Unsupported composition schema version")
  let points = (:)
  let point(position) = {
    let xy = if type(position) == array { position } else {
      let nested = position.at("position", default: position)
      (nested.at("x", default: nested.at("left", default: none)),
       nested.at("y", default: nested.at("top", default: none)))
    }
    assert(xy.len() == 2, message: "Expected [x, y] in composition")
    for coordinate in xy {
      assert(type(coordinate) == int or type(coordinate) == float, message: "Composition coordinates must be numbers")
      assert(coordinate > -1000000000 and coordinate < 1000000000, message: "Composition coordinates must be finite")
    }
    xy
  }
  if "placements" in payload {
    for item in payload.placements {
      assert(not (item.key in points), message: "Duplicate composition key: " + item.key)
      points.insert(item.key, point(item))
    }
  } else {
    for (key, position) in payload.p { points.insert(key, point(position)) }
  }
  points
}

#let python-state(state, title: none, columns: 2, positions: (:), node-width: 120pt,
  composition: auto, font: auto, mono-font: "JetBrains Mono", edge-color: rgb("#24292e"), boxed: false) = context {
  assert(type(state) == dictionary, message: "State must be a dictionary")
  assert(columns > 0 and type(columns) == int, message: "columns must be a positive integer")
  let objects = entries(state.objects)
  let frames = entries(state.at("frames", default: (:)))
  let ids = objects.map(entry => entry.at(0))
  assert(ids.dedup().len() == ids.len(), message: "Duplicate object IDs")
  let frame-ids = frames.map(entry => entry.at(0))
  assert(frame-ids.dedup().len() == frame-ids.len(), message: "Duplicate frame IDs")
  let ink = rgb("#24292e")
  let blue = edge-color
  let row-height = 15pt
  let padding = 8pt
  let gap = 35pt
  let nodes = ()
  let reference(target, label) = {
    assert(ids.contains(target), message: "Unknown object: " + target)
    (target: target, label: str(label))
  }
  for (id, frame) in frames {
    let names = frame.bindings.map(binding => binding.name)
    assert(names.dedup().len() == names.len(), message: "Duplicate binding in frame " + id)
    let refs = frame.bindings.map(binding => reference(binding.object, binding.name))
    nodes.push((key: "frame:" + id, heading: frame.at("name", default: id), refs: refs, body: []))
  }
  for (id, object) in objects {
    let kind = object.at("type", default: object.at("kind", default: none))
    assert(("int", "float", "bool", "NoneType", "str", "list", "dict", "function", "object").contains(kind),
      message: "Unsupported type for " + id)
    let value = object.value
    let valid = if kind == "int" { type(value) == int }
      else if kind == "float" { type(value) == float or type(value) == int }
      else if kind == "bool" { type(value) == bool }
      else if kind == "NoneType" { value == none }
      else if kind == "str" or kind == "function" { type(value) == str }
      else if kind == "list" or kind == "dict" { type(value) == array }
      else { true }
    assert(valid, message: "Invalid value for " + id + " (" + kind + ")")
    let refs = ()
    if kind == "list" {
      for (index, item) in value.enumerate() { refs.push(reference(item.object, index)) }
    } else if kind == "dict" {
      for (index, pair) in value.enumerate() {
        refs.push(reference(pair.key.object, str(index) + ".key"))
        refs.push(reference(pair.value.object, str(index) + ".value"))
      }
    }
    let body = if refs.len() == 0 { raw(literal(value, kind)) } else { [] }
    let details = object.at("details", default: none)
    if details != none {
      let lines = if type(details) == array { details }
        else if type(details) == dictionary { details.pairs().map(p => str(p.at(0)) + ": " + str(p.at(1))) }
        else { (str(details),) }
      for detail in lines { body += [#linebreak()#raw(detail)] }
    }
    nodes.push((key: "object:" + id, heading: "type: " + kind, refs: refs, body: body))
  }
  set text(font: if font == auto { text.font } else { font }, size: 10pt, fill: ink)
  show raw: set text(font: mono-font, size: 8.5pt)
  set par(leading: 3pt)
  set block(spacing: 0pt)
  let placements = (:)
  let column-count = columns + if frames.len() > 0 { 1 } else { 0 }
  let bottoms = range(column-count).map(_ => 0pt)
  for (index, node) in nodes.enumerate() {
    let col = if index < frames.len() { 0 }
      else { calc.rem(index - frames.len(), columns) + if frames.len() > 0 { 1 } else { 0 } }
    let body-height = if node.body == [] { 0pt } else { measure(block(width: node-width - 2 * padding, node.body)).height + 5pt }
    let height = 2 * padding + row-height + row-height * node.refs.len() + body-height
    let point = positions.at(node.key, default: (12pt + col * (node-width + gap), bottoms.at(col)))
    assert(point.at(0) >= 0pt and point.at(1) >= 0pt, message: "Positions must be non-negative lengths")
    placements.insert(node.key, (x: point.at(0), y: point.at(1), height: height))
    bottoms.at(col) = calc.max(bottoms.at(col), point.at(1) + height + 24pt)
  }
  let imported = composition-points(if composition == auto { state.at("composition", default: none) } else { composition })
  if imported.len() > 0 {
    assert(positions.len() == 0, message: "Use either browser composition or explicit print positions")
    assert(imported.keys().sorted() == placements.keys().sorted(),
      message: "Composition must contain exactly the current frame/object IDs; export it again after adding or removing nodes")
    let min-x = calc.min(..imported.values().map(p => p.at(0)))
    let min-y = calc.min(..imported.values().map(p => p.at(1)))
    // Preserve relative positions. Expand coordinates uniformly if the print font
    // makes boxes overlap; the whole drawing is then fitted to the text width.
    let unit = 0.75pt
    let keys = imported.keys()
    for i in range(keys.len()) {
      for j in range(i + 1, keys.len()) {
        let a = imported.at(keys.at(i))
        let b = imported.at(keys.at(j))
        let dx = calc.abs(a.at(0) - b.at(0))
        let dy = calc.abs(a.at(1) - b.at(1))
        assert(dx > 0 or dy > 0, message: "Composition has coincident nodes")
        let top-key = if a.at(1) <= b.at(1) { keys.at(i) } else { keys.at(j) }
        let horizontal = if dx > 0 { (node-width + 12pt) / dx } else { 1000000pt }
        let vertical = if dy > 0 { (placements.at(top-key).height + 12pt) / dy } else { 1000000pt }
        unit = calc.max(unit, calc.min(horizontal, vertical))
      }
    }
    for (key, p) in imported {
      let item = placements.at(key)
      item.x = 12pt + (p.at(0) - min-x) * unit
      item.y = (p.at(1) - min-y) * unit
      placements.insert(key, item)
    }
  }
  let width = 1pt
  let height = 1pt
  for (_, point) in placements { width = calc.max(width, point.x + node-width); height = calc.max(height, point.y + point.height) }
  let segment(a, b) = line(start: a, end: b, stroke: 0.8pt + blue)
  let drawing = block(width: width + 12pt, height: height + 16pt, {
    // Edges behind boxes; offset lanes keep references distinguishable.
    for node in nodes {
      let from = placements.at(node.key)
      for (index, ref) in node.refs.enumerate() {
        let dest = placements.at("object:" + ref.target)
        let start = (from.x + node-width, from.y + padding + row-height * (index + 1.5))
        let end = (dest.x, dest.y + 12pt)
        let lane = start.at(0) + 8pt + calc.rem(index, 5) * 3pt
        let points = if dest.x > from.x {
          (start, (lane, start.at(1)), (lane, end.at(1)), end)
        } else {
          let below = calc.max(from.y + from.height, dest.y + dest.height) + 8pt + calc.rem(index, 3) * 3pt
          (start, (lane, start.at(1)), (lane, below), (dest.x - 8pt, below), (dest.x - 8pt, end.at(1)), end)
        }
        for i in range(points.len() - 1) { place(top + left, segment(points.at(i), points.at(i + 1))) }
        place(top + left, segment((end.at(0) - 4pt, end.at(1) - 2.5pt), end))
        place(top + left, segment((end.at(0) - 4pt, end.at(1) + 2.5pt), end))
      }
    }
    for node in nodes {
      let point = placements.at(node.key)
      place(top + left, dx: point.x, dy: point.y,
        block(width: node-width, height: point.height, stroke: 0.6pt + ink, radius: 2pt, fill: white, inset: padding, {
          block(height: row-height, text(weight: if node.key.starts-with("frame:") { "bold" } else { "regular" }, node.heading))
          for ref in node.refs {
            block(height: row-height, width: 100%)[#raw(ref.label)#place(top + right, dy: row-height / 2 - 1.8pt, circle(radius: 1.8pt, fill: blue))]
          }
          node.body
        }))
    }
  })
  block(width: 100%, above: 12pt, below: 12pt, stroke: if boxed { 0.6pt + ink } else { none }, radius: 2pt, inset: 10pt, breakable: false, {
    if title != none { text(weight: "bold", title); v(8pt) }
    layout(size => {
      if width + 12pt > size.width { scale(x: size.width / (width + 12pt) * 100%, y: size.width / (width + 12pt) * 100%, reflow: true, drawing) }
      else { drawing }
    })
  })
}
