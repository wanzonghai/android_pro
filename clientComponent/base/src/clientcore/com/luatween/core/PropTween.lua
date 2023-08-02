--
-- Author: senji
-- Date: 2014-02-08 15:05:53
--
PropTween = class_quick("PropTween");

function PropTween:ctor(target, property, start, change, name, isPlugin, nextNode, priority)
    self.target = target;
    self.property = property;
    self.start = start;
    self.change = change;
    self.name = name;
    self.isPlugin = isPlugin;
    if nextNode then
        nextNode.prevNode = self;
        self.nextNode = nextNode;
    end
    self.priority = priority;
end