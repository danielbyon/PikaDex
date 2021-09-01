//
//  MachineList.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/20/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct MachineList: View {

    let title: String
    let game: Game
    
    @FetchRequest private var machines: FetchedResults<Machine>
    @State private var selectedMachineType: MachineType = .tm
    @State private var searchText = ""

    private var segmentedControlValues: [MachineType] {
        var values: [MachineType] = []
        if !tms.isEmpty {
            values.append(.tm)
        }
        if !hms.isEmpty {
            values.append(.hm)
        }
        if !trs.isEmpty {
            values.append(.tr)
        }
        return values
    }
    private var tms: [Machine] { machines.filter { $0.type == .tm } }
    private var hms: [Machine] { machines.filter { $0.type == .hm } }
    private var trs: [Machine] { machines.filter { $0.type == .tr } }
    private var currentMachines: [Machine] {
        switch selectedMachineType {
        case .tm:
            return tms
        case .hm:
            return hms
        case .tr:
            return trs
        }
    }
    private var filteredMachines: [Machine] {
        if searchText.isEmpty {
            return currentMachines
        } else {
            return currentMachines.filter { $0.move.canonicalName.contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        List {
            AlternatingBackgroundForEach(filteredMachines) {
                self.cell(for: $0)
            }
        }
        .searchable(text: $searchText, prompt: "Search for \(title)")
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                segmentedControl()
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle(title)
    }

    init(title: String, game: Game) {
        self.title = title
        self.game = game
        _machines = FetchRequest(fetchRequest: Machine.allFetchRequest(for: game))
    }

    private func segmentedControl() -> SegmentedControl<MachineType>? {
        guard segmentedControlValues.count > 1 else { return nil }
        return SegmentedControl(selectedSegment: $selectedMachineType, segments: segmentedControlValues)
    }

    private func cell(for machine: Machine) -> some View {
        NavigationLink(destination: MoveDetail(move: machine.move, game: game)) {
            MachineCell(machine: machine, game: game)
        }
    }

}

struct MachineList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MachineList(title: "TMs / TRs", game: .sword)
                .injectDependencies()
        }
    }
}

private struct MachineCell: View {

    let machine: Machine
    let game: Game

    var body: some View {
        HStack {
            MoveCell(move: machine.move, game: game)
            Text("\(machine.type.rawValue) \(NumberFormatter.twoDigit.string(from: NSNumber(value: machine.number)) ?? "")")
        }
        .contentShape(Rectangle())
        .monospacedBody()
    }

}
