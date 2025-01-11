define z1 = Character('小张_正常', color="#b97a87")
define z2 = Character('小张_思考', color="#b97a87")
define z3 = Character('小张_不解', color="#b97a87")
define z4 = Character('小张_快乐', color="#b97a87")
define z5 = Character('小张_难过', color="#b97a87")
define z6 = Character('小张_无语', color="#b97a87")

define m1 = Character('毛毛_正常', color="#676c44")
define m2 = Character('毛毛_思考', color="#676c44")
define m3 = Character('毛毛_不解', color="#676c44")
define m4 = Character('毛毛_快乐', color="#676c44")
define m5 = Character('毛毛_苦涩', color="#676c44")
define m6 = Character('毛毛_尴尬', color="#676c44")

define c1 = Character('小孩_正常', color="#ffca33")
define c2 = Character('小孩_思考', color="#ffca33")
define c3 = Character('小孩_好奇', color="#ffca33")
define c4 = Character('小孩_快乐', color="#ffca33")
define c5 = Character('小孩_失望', color="#ffca33")

define o1 = Character('智者_正常', color="#64869e")
define o2 = Character('智者_思考', color="#64869e")
define o3 = Character('智者_不解', color="#64869e")
define o4 = Character('智者_快乐', color="#64869e")
define o5 = Character('智者_失望', color="#64869e")

define s = Character("我", colour = "#2b333e")


label start
scene bg chemlab
with fade
scene bg chemlab

s "这是哪...怎么感觉脑子模模糊糊的...化学实验室...?"
"好像能听到那边有两个人在说话..."
z1 "好，镁条准备好了。燃烧的时候你会感受到明亮的光和大量的热。毛毛，你觉得这说明了什么？"
m1 "光和热确实是很直观的变化，但我更感兴趣的是燃烧后剩下的白色粉末。它和原来的镁条显然不同。这是不是意味着物质发生了变化？"
z1 "你是对的。镁条和氧气发生化学反应，生成了氧化镁。这就是**物质变化**。而我刚刚说到的光和热，则是**能量变化**的表现。"
m2 "在化学反应中，其实是两种变化同时发生。"
m3 "物质变化是主要的现象，能量变化只是伴随现象？"
z1 "不完全是。我在书上读到过，物质变化和能量变化是相互联系的。很多反应需要吸收能量才能开始，这叫**“活化能”**。能量变化也会影响反应的快慢——"
z3 "那边的家伙，你在做什么？"
s "（环顾四周）啊？你是说我？？"
"怎么办...怎么办...我是谁我在哪我是来做什么的？？我怎么知道啊，又没有人告诉我！"
m6 "喂，你不要吓到新来的伙伴了！同学，请问你刚刚听到了我们的对话嘛？"
s "嗯，你们刚刚是在讨论化学反应中的两大变化...？"
"（沉默）"
s "哎哎哎？怎么尬住了...不是吧..."
m1 "你是新来和我们一起探索科学世界的同学吧？"
s "什么什么？？我是吗？"
z3 "（盯）"
"犹豫什么。你是。"
s "怎么还有和我对话的画外音...？？这是什么设定啊？"
z3 "如果来这里没事的话，最好不要耽误我们学习。"s: "我是，我是！"
z1: "名字？"
s: "名字..."
default name = "小俞"
name = input("你的名字是[1]")

s: "我叫[name]"
m4: "很高兴认识你，[name]。我叫毛毛，刚刚在和我说话的是小张。之后我们会一起学习科学，构建科学知识体系。"
z1: "[name]是吧？你刚刚说听到了我们的对话。那我倒要问问你：化学反应中存在的两大变化是什么？"
menu:
    "参考之前的对话结论":
        jump refer_back_conclusion
    "参考之前的实验":
        jump refer_back_experiment
    "邀请补充想法":
        jump inv_to_build_on
    
label refer_back_conclusion:
answers = input("化学反应中存在两大变化，即[1]变化和[2]变化")
judgement = judge(2, answers, set = true, "能量", "物质")
    if judgement:
        z1 "还可以啊，刚刚有注意**积极倾听**，还记得住我们说了什么！走吧，带你去实验室看看。"
        jump end
    else:
        m3 "我们刚刚在做实验。"
  
label refer_back_experiment:
s "嗯，我记得，你们刚刚在做燃烧镁条的实验。"
m1 "是的，让我为你复现一下刚刚的实验！"
show MgOxidation
z1 "这里我们可以观察到两个明显的变化。一个是反应的物质变化，镁条从最开始闪亮的银白色变成了白色的灰烬。"
menu:
    "继续推理":
        jump reasoning_MgOxidation_SubstanceChange
label reasoning_MgOxidation_SubstanceChange:
s "反应过程中，镁条与空气中的氧气发生反应。镁（Mg）与氧（O₂）结合，形成了氧化镁（MgO）。"
m1 "除此之外，你看，镁条燃烧时发出的亮光和热量，都是能量的表现。"
menu:
    "反思总结":
    jump reflection_MgOxidation
label reflection_MgOxidation:
s "原来是能量啊...所以镁条燃烧不仅仅是**物质**的变化，而且也是**能量**的变化。"
z1 "嗯，是这样的。走吧，带你去实验室看看。"
jump end

label inv_to_build_on:
s "哎...化学反应中的两大变化是什么呢？我也不是特别确定答案，因为刚刚没有看到你们实验的过程。如果可以的话，你们是否愿意补充说明一下？"
m1 "那就让我们为你复现一下刚刚的实验吧。"
show MgOxidation
z1 "这里我们可以观察到两个明显的变化。一个是反应的**物质变化**，镁条从最开始闪亮的银白色变成了白色的灰烬。"
menu:
    "继续推理":
    jump reasoning_MgOxidation_SubstanceChange
label reasoning_MgOxidation_SubstanceChange:
s "反应过程中，镁条与空气中的氧气发生反应。镁（Mg）与氧（O₂）结合，形成了氧化镁（MgO）。"
m1 "除此之外，你看，镁条燃烧时发出的亮光和热量，都是能量的表现。"
menu:
  "反思总结":
  jump reflection_MgOxidation
label reflection_MgOxidation:
s "原来是能量啊...所以镁条燃烧不仅仅是**物质**的变化，而且也是**能量**的变化。"
z1 "嗯，是这样的。走吧，带你去实验室看看。"
jump end

label end

