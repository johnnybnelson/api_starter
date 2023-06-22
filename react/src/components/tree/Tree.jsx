import TreeNode from "./TreeNode";

function Tree({ treeData }) {

    console.log("treeData", treeData);

    const treeStuff = (node) => {
        return <TreeNode node={node} key={node.key} />
    }
    var newTree = [{ treeData }];
    var tree = newTree.map(treeStuff);

    return (


        < ul >
            {tree}
        </ul >
    );
}
export default Tree;